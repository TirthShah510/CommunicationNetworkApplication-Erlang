-module(calling).
-author("Tirth").

-export([processSpawn/3, people/2]).
processSpawn(Key, Value, Master) ->

  PID = spawn(calling, people, [Key, Master]),
  register(Key, PID),
  Sender = Key,
  lists:foreach(fun(T) -> Key ! {finished, Sender, T} end, Value).

people(Key, Master) ->

  receive
    {finished, Sender, T} ->
      T ! {intro, Sender, T},
      people(Key, Master);

    {intro, Sender, T} ->
      {_, _, Ms} = os:timestamp(),
      Master ! {finishedCalling, Sender, T, Ms},
      timer:sleep(rand:uniform(100)),
      Sender ! {reply, T},
      people(Key, Master);

    {reply, T} ->
      {_, _, Ms} = os:timestamp(),
      Master ! {finishedReply, Key, T, Ms},
      people(Key, Master)
  after 5000 -> io:fwrite("~nProcess ~p has received no calls for 5 seconds, ending...~n", [Key])
  end.

