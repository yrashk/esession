defprotocol Http.Session.Storage do
  def update(storage, id, dict)
  def get(storage, id)
  def dump(storage, session)
end