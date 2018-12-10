-module(rabbit_queue_info_sup).
-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

start_link() ->
	supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
	{ok, {{one_for_one, 1, 5}, [child_spec()]}}.

child_spec() ->
    #{id => queue_info_worker,
      start => {rabbit_queue_info_worker, start_link, []},
      restart => permanent,
      type => worker}.
