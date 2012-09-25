defrecord Http.Session, id: nil, storage: nil, dict: HashDict.new do

  def put(name, value, session) do
    new_dict = HashDict.put(dict(session), name, value)
    new_storage = Http.Session.Storage.update(storage(session), id(session), 
                                              new_dict)
    storage(new_storage, dict(new_dict, session))
  end
  def get(name, default // nil, session) do
    HashDict.get(dict(session), name, default)
  end
end