defmodule ExMessageBus.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  import Supervisor.Spec

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: ExMessageBus.Worker.start_link(arg)
      # {ExMessageBus.Worker, arg},
      ExMessageBus.MessageBus.Worker
    ]

    redis_env = Application.get_env(:ex_message_bus, :redis)

    redis_port = Keyword.get(redis_env, :port) |> String.to_integer
    redis_host = Keyword.get(redis_env, :host)

    redix_workers = [
      Supervisor.child_spec({Redix, port: redis_port, host: redis_host, name: RedixConnectionBlocking}, id: {Redix, 1}),
      Supervisor.child_spec({Redix, port: redis_port, host: redis_host, name: RedixConnection}, id: {Redix, 2})

    ]

    children = redix_workers ++ children

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ExMessageBus.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
