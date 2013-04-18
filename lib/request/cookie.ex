defrecord Http.Session.Request.Cookie, name: "_session", path: "/", options: [], server: :cowboy, storage: nil

defimpl Http.Session.Request, for: Http.Session.Request.Cookie do
  alias :cowboy_req, as: Req

  def get(Http.Session.Request.Cookie[server: :cowboy, name: name, storage: storage], req) do
     case Req.cookie(name, req) do
       {:undefined, _req} -> binary = ""
       {binary, _req} when is_binary(binary) -> binary
     end
     Http.Session.Storage.get storage, binary
  end

  def set(Http.Session.Request.Cookie[server: :cowboy, options: options, storage: storage, name: name], req, session, opts // []) do
     Req.set_resp_cookie(name, Http.Session.Storage.dump(storage, session), Keyword.merge(options, opts), req)
  end

end