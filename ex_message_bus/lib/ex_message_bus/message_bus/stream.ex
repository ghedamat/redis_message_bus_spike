# TODO
# * loop to deal with pending messages/cleanup on non acked stuff
# * move to a gen server that proces messages by logging them
# * check what happens on crash (simulate long processing??)
# * fix consumer_name
# * scope errors timeout
defmodule ExMessageBus.MessageBus.Stream do
  @stream_name :pn_message_bus
  @group_name :ex_mb

  def create_group do
    Redix.command(RedixConnection, ["XGROUP", "CREATE", @stream_name, @group_name, "$", "MKSTREAM"])
  end

  def remove_consumer do
    Redix.command(RedixConnection, ["XGROUP", "DELCONSUMER", @stream_name, @group_name, consumer_name])
  end

  def add(name, msg) do
    serialized_msg = Jason.encode!(msg)
    Redix.command(RedixConnection, ["XADD", @stream_name, "*", "name", name, "payload", serialized_msg])
  end

  def pop do
    [id, vals ] = fetch
    ack(id)

    vals =
      vals
      |> Enum.chunk_every(2)
      |> Map.new(fn [a, b] -> {String.to_atom(a), b} end)

    payload = vals[:payload] |> Jason.decode!
    %{ vals | payload: payload }
  end

  def fetch do
    ret = Redix.command(RedixConnectionBlocking, ["XREADGROUP", "COUNT", 1, "BLOCK", 4000, "GROUP", @group_name, consumer_name, "STREAMS", @stream_name, ">"])
    case ret do
      {:ok, [[_| [[vals]]]]} -> vals
      {:ok, nil}  ->
        fetch # this loops when blockign expires ( timeout needs to be lower than the Redix timeout of 5000)
    end
  end

  def ack(id) do
    Redix.command(RedixConnection, ["XACK", @stream_name, @group_name, id])
  end

  def consumer_name do
    inspect(self())
  end
end
