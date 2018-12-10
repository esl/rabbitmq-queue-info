-module(rabbit_queue_info_worker).

-export([start_link/0]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2]).

-export([list_queues/0]).

-behaviour(gen_server).

-define(VHOST, <<"/">>).


%% API

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

list_queues() ->
    gen_server:call(?MODULE, list_queues).

%% Callbacks

init([]) ->
    {ok, #{}}.

handle_call(list_queues, _From, State) ->
    Nodes = rabbit_mnesia:cluster_nodes(running),
    Ref = make_ref(),
    Chunks = length(Nodes),
    ok = rabbit_amqqueue:emit_info_all(Nodes, ?VHOST, [name, messages_ready],
                                       Ref, self()),
    Queues = receive_queues(Ref, Chunks),
    {reply, Queues, State};
handle_call(_Msg, _From, State) ->
    {reply, not_implemented, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

%% Helpers

receive_queues(Ref, Chunks) ->
    receive_queues(Ref, Chunks, []).

receive_queues(Ref, Chunks, Acc) ->
    receive
        {Ref, finished} when Chunks == 1 ->
            Acc;
        {Ref, finished} ->
            receive_queues(Ref, Chunks - 1, Acc);
        {Ref, {timeout, _T}} ->
            receive_queues(Ref, Chunks, Acc);
        {Ref, []} ->
            receive_queues(Ref, Chunks, Acc);
        {Ref, error, _} ->
            receive_queues(Ref, Chunks, Acc);
        {error, _} ->
            Acc;
        {Ref, Items, continue} ->
            {_, _, _, Name} = proplists:get_value(name, Items),
            MsgReady = proplists:get_value(messages_ready, Items),
            receive_queues(Ref, Chunks, [#{name => Name,
                                           messages_ready => MsgReady} | Acc])
    end.
