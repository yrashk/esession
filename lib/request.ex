defprotocol Http.Session.Request do
  @only [Record]
  def get(handler, request)
  def set(handler, request, session)
  def set(handler, request, session, opts)

end