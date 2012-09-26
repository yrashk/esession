##
## Based on work by Alex X. Liu and others: http://www.cse.msu.edu/~alexliu/publications/Cookie/cookie.pdf
##
##
## WARNING: Please understand that there is no guarantee made about how secure this thing really is
##          This code's author is clueless about cryptography and security
##
defrecord Http.Session.Storage.Secure, key: nil, ivec: nil,
                                       id: Http.Session.Name.UUID,
                                       serialization: Http.Session.Serialization.Term do
end

defimpl Http.Session.Storage, for: Http.Session.Storage.Secure do
  import Bitwise
  def update(storage, _id, _dict), do: storage

  def get(storage, binary) do
    case :binary.split(:cowboy_http.urldecode(binary), ";", [:global]) do
       [session_key, ivec, hunk] ->
           ivec = :base64.decode(ivec)
           case validate(:base64.decode(hunk), session_key, storage.key, ivec) do
               false -> 
                  new(storage)
               {_, << sec_data_len :: [size(1), big, unsigned, integer, unit(16)],
                      sec_data :: [size(sec_data_len), binary] >>} -> new(storage).dict(storage.serialization.decode(sec_data))
           end
       _ -> 
         new(storage)
   end
  end

  def dump(_storage, session) do
    make(session.storage, session.id, "", session.storage.serialization.encode(session.dict))
  end

  defp new(storage) do
    ivec = storage.id.generate_raw  
    Http.Session.new id: storage.id.generate, storage: storage.ivec(ivec)
  end

  defp make(storage, session_key, data, sec_data) do
    sec_data = << size(sec_data) :: [size(1), big, unsigned, integer, unit(16)],
                  sec_data :: binary >>
    :cowboy_http.urlencode(iolist_to_binary([session_key, ";", :base64.encode(storage.ivec), ";",
                                             :base64.encode(generate(data, sec_data, session_key, storage.key, storage.ivec))]))
  end

  ###

  defp generate(data, sec_data, session_key, key, ivec) do
    enc = <<size(data) :: [size(1), big, unsigned, integer, unit(16)],
            data :: binary,
            size(sec_data) :: [size(1), big, unsigned, integer, unit(16)],
            sec_data :: binary>>
    enc_data = :crypto.aes_cbc_128_encrypt(key, ivec, pad(16, enc))
    hmac = :crypto.sha_mac([data, enc_data, session_key], key)
    <<size(data) :: [size(1), big, unsigned, integer, unit(16)],
     data :: binary,
     size(enc_data) :: [size(1), big, unsigned, integer, unit(16)],
     enc_data :: binary,
     size(hmac) :: [size(1), big, unsigned, integer, unit(16)],
     hmac :: binary>>
  end



  defp validate(hunk, session_key, key, ivec) do
    <<data_len :: [size(1), unit(16), big, unsigned, integer],
      data :: [size(data_len), binary],
      enc_data_len :: [size(1), unit(16), big, unsigned, integer],
      enc_data :: [size(enc_data_len), binary],
      hmac_len :: [size(1), unit(16), big, unsigned, integer],
      hmac :: [size(hmac_len), binary] >> = hunk
     dec_data = :crypto.aes_cbc_128_decrypt(key, ivec, enc_data) 
     mac = :crypto.sha_mac([data, enc_data, session_key], key)
     if secure_compare(mac, hmac) do
       case dec_data do
         <<res_data_len :: [size(1), unit(16), big, unsigned, integer],
           res_data :: [size(res_data_len), binary],
           res_sec_data_len :: [size(1), unit(16), big, unsigned, integer],
           res_sec_data :: [size(res_sec_data_len), binary],
           _ :: binary>> -> {res_data, res_sec_data}
         _ -> false
       end
     else
       false
     end  
  end

  defp secure_compare(a,b), do: secure_compare(a,b,0)

  defp secure_compare(<<>>,<<>>,0), do: true
  defp secure_compare(<<a :: [size(1), unit(8)], at :: binary>>,
                      <<b :: [size(1), unit(8)], bt :: binary>>,
                      acc) do
    secure_compare(at,bt, bor(acc, bxor(a,b)))
  end
  defp secure_compare(_,_,_), do: false

  defp pad(width, binary) do
    case rem(width - rem(size(binary), width), width) do
      0 -> binary;
      n -> n = n*8 ; <<binary :: binary, 0 :: [size(n)]>>
    end
  end

end