defmodule ExMessageBus.MessageBus.Worker do
  use GenServer
  alias ExMessageBus.MessageBus.Stream

  def start_link(env \\ []) do
    GenServer.start_link(__MODULE__, [], [name: __MODULE__])
  end

  @impl true
  def init(args) do
    {:ok, [], {:continue, :start_loop}}
  end

  def handle_continue(:start_loop, state) do
    Stream.create_group

    start_loop

    {:noreply, state}
  end

  @impl true
  def terminate(reason, state) do
    IO.inspect(:terminate)
  end

  # internals
  def start_loop do
    msg = Stream.pop
    IO.puts "message received, processing..."
    IO.inspect msg
    IO.puts "message processed"
    start_loop
  end
end

