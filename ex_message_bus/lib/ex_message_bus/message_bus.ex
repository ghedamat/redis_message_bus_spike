# TODO
# * loop to deal with pending messages/cleanup on non acked stuff
# * move to a gen server that proces messages by logging them
# * check what happens on crash (simulate long processing??)
# * fix consumer_name
# * scope errors timeout
defmodule ExMessageBus.MessageBus do
  use GenServer

  @stream_name :pn_message_bus
  @group_name :ex_mb

  def create_group do
    Redix.command(RedixConnection, ["XGROUP", "CREATE", @stream_name, @group_name, "$", "MKSTREAM"])
  end

  def add(name, msg) do
    serialized_msg = Jason.encode!(msg)
    Redix.command(RedixConnection, ["XADD", @stream_name, "*", "name", name, "payload", serialized_msg])
  end

  def get do
    [id, vals ] = getp
    vals =
      vals
      |> Enum.chunk_every(2)
      |> Map.new(fn [a, b] -> {String.to_atom(a), b} end)

    ack(id)

    payload = vals[:payload] |> Jason.decode!
    vals = %{ vals | payload: payload}


    %{id: id, values: vals}
  end

  def getp do
    case Redix.command(RedixConnection, ["XREADGROUP", "COUNT", 1, "BLOCK", 0, "GROUP", @group_name, consumer_name, "STREAMS", @stream_name, ">"]) do
      {:ok, [[_| [[vals]]]]} -> vals
      {:error, _} -> getp # TODO scope this to the timeout error
    end
  end

  def ack(id) do
    Redix.command(RedixConnection, ["XACK", @stream_name, @group_name, id])
  end

  def consumer_name do
   "foo" # TODO use PID?
  end

  def start_link(env \\ []) do
    GenServer.start_link(__MODULE__, [], [])
  end

  def init([]) do
    {:ok, []}
  end

  def handle_call({:msg, _from, state}) do
    {:reply, nil, state}
  end
end
