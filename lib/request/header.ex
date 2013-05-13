defrecord Http.Session.Request.Header, name: "Session", server: :cowboy, storage: nil

defimpl Http.Session.Request, for: Http.Session.Request.Header do
  alias :cowboy_req, as: Req

  def get(Http.Session.Request.Header[server: :cowboy, name: name, storage: storage], req) do
     case Req.header(name, req) do
       {:undefined, _req} -> binary = ""
       {binary, _req} when is_binary(binary) -> binary
     end
     Http.Session.Storage.get storage, binary
  end

  def set(Http.Session.Request.Header[server: :cowboy, storage: storage, name: name], req, session, _opts // []) do
     Req.set_resp_header(name, Http.Session.Storage.dump(storage, session), req)
  end

end