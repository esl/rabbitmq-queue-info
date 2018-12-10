-module(rabbit_queue_info_handler).

-export([init/2]).

init(Req0, _Opts) ->
    #{max_len := MaxLenBin} = cowboy_req:match_qs([{max_len, [], undefined}], Req0),
    Queues = rabbit_queue_info_worker:list_queues(),
    QueuesFiltered = case MaxLenBin of
                         undefined ->
                             Queues;
                         _ ->
                             MaxLen = list_to_integer(binary_to_list(MaxLenBin)),
                             lists:filter(fun(Q) -> is_below_limit(Q, MaxLen) end,
                                          Queues)
                     end,
    QueuesJSON = jsx:encode(QueuesFiltered),
    Req = cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>},
                           QueuesJSON, Req0),
    {ok, Req, no_state}.

is_below_limit(#{messages_ready := MsgReady}, MaxLen) when MsgReady =< MaxLen ->
    true;
is_below_limit(_, _) ->
    false.
