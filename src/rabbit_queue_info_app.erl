-module(rabbit_queue_info_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).

start(_Type, _Args) ->
  start_http_server(),
	rabbit_queue_info_sup:start_link().

stop(_State) ->
	ok.

start_http_server() ->
    Dispatch = cowboy_router:compile([{'_', [{"/list_queues",
                                              rabbit_queue_info_handler, []}]}]),
    {ok, _} = cowboy:start_clear(http, [{port, 8000}],
                                 #{env => #{dispatch => Dispatch}}).
