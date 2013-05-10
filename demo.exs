# Code.load_file "demo.exs" ; Demo.start
defmodule Demo do
  alias :cowboy, as: Cowboy
  alias :cowboy_req, as: Req

  def start do
    :ok = Application.start(:cowboy)
    :ok = Application.start(:esession)

    session_storage = Http.Session.Storage.Secure.new key: "26skV8PjTfd9xpaVtzXCmMEaAkefXgUu"
#    session_storage = Http.Session.Storage.ETS.new
    session_request = Http.Session.Request.Cookie.new storage: session_storage

    dispatch = [
      {:_, [
        {"/", Demo, [session_request: session_request]},
      ]},
    ] |> :cowboy_router.compile

    {:ok, _} = Cowboy.start_http(Demo.HttpListener, 100,
                                  [port: 8080],
                                  [env: [dispatch: dispatch]])

    IO.puts "http://localhost:8080"
  end

  def init({:tcp, :http}, req, opts), do: {:ok, req, opts}

  def handle(req, opts) do
    request = opts[:session_request]
    session = Http.Session.Request.get request, req
    session = session.put :ctr, (session.get :ctr, 0) + 1
    req = Http.Session.Request.set request, req, session, max_age: Http.Session.Time.minutes(10)
    {:ok, req} = Req.reply(200, [], "#{inspect(session)}", req)
    {:ok, req, opts}
  end

  def terminate(_req, _state), do: :ok
end