#! /usr/bin/env escript
%%! -pa ebin
-compile({parse_transform, elixir_transform}).
-compile(export_all).
-mode(compile).

main(_) ->
  ok = 'Elixir.Application':start(cowboy),
  ok = 'Elixir.Application':start(esession),
  SessionStorage = 'Elixir.Http.Session.Storage.Secure':new(orddict:from_list([{key, <<"26skV8PjTfd9xpaVtzXCmMEaAkefXgUu">>}])),
  %% SessionStorage = 'Elixir.Http.Session.Storage.ETS':new(),
  SessionRequest = 'Elixir.Http.Session.Request.Cookie':new(orddict:from_list([{storage, SessionStorage}])),
  Dispatch = [
    {'_', [{'_', ?MODULE, [{session_request, SessionRequest}]}]}
  ],
  cowboy:start_http(demo_http_listener, 100, [{port, 8080}], [{dispatch, Dispatch}]),
  io:format("http://localhost:8080~n"),  
  receive ok -> ok end.

init({tcp, http}, Req, Opts) -> {ok, Req, Opts}.
handle(Req, Opts) ->
  Request = proplists:get_value(session_request, Opts),
  Session0 = 'Elixir.Http.Session.Request':get(Request, Req),
  Session1 = Session0:put(ctr, Session0:get(ctr,0) + 1),
  Req1 = 'Elixir.Http.Session.Request':set(Request, Req, Session1, orddict:from_list([{max_age, 'Elixir.Http.Session.Time':minutes(10)}])),
  {ok, Req2} = cowboy_req:reply(200, [], io_lib:format("~p~n",[Session1]), Req1),
  {ok, Req2, Opts}.
terminate(_Req, _State) -> ok.
