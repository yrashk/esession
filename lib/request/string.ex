defrecord Http.Session.Request.String, storage: nil

defimpl Http.Session.Request, for: Http.Session.Request.String do

  def get(Http.Session.Request.String[storage: storage], binary) do
     Http.Session.Storage.get storage, binary
  end

  def set(Http.Session.Request.String[storage: storage], _, session, _opts // []) do
     Http.Session.Storage.dump(storage, session)
  end

end