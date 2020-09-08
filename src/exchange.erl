-module(exchange).
-author("Tirth").

-export([start/0, master/0]).

start() ->
  {ok,DataMap} = file:consult("calls.txt"),
  io:fwrite("** Calls to be made **~n"),
  [io:fwrite("~p : ~p~n", [H, T]) || {H, T} <- DataMap],
  io:fwrite("~n"),
  [(calling:processSpawn(H,T,self())) || {H,T} <- DataMap],
  master().

master() ->

  receive
    {finishedReply, Key, T, Ms} ->
      io:format("~p received reply message from ~p [~w]~n", [Key,T, Ms]),
      master();
    {finishedCalling, Key, T, Ms} ->
      io:format("~p received intro message from ~p [~w]~n", [T, Key, Ms]),
      master()
  after 10000 -> io:fwrite("~nMaster has received no calls for 10 seconds, ending...~n")
  end.