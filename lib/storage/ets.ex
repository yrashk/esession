defrecord Http.Session.Storage.ETS, tid: nil,
                                    id: Http.Session.Name.UUID do
  defoverridable new: 1
  def new(opts) do
    super(Keyword.merge([tid: :ets.new(__MODULE__, [:ordered_set, :public])], opts))
  end
end

defimpl Http.Session.Storage, for: Http.Session.Storage.ETS do
  alias :ets, as: ETS
  def update(Http.Session.Storage.ETS[tid: tid] = storage, id, dict) do
   ETS.insert(tid, {id, dict})
   storage
  end

  def get(Http.Session.Storage.ETS[tid: tid] = storage, id) do
    case ETS.lookup(tid, id) do
     [{^id, dict}] -> new(storage).id(id).dict(dict)
     _ -> new(storage)
    end
  end

  def dump(_storage, session) do
     session.id
  end

  defp new(storage) do
    Http.Session.new id: storage.id.generate, storage: storage
  end

end
