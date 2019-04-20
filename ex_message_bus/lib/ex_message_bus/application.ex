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
    ]

    redis_env = Application.get_env(:ex_message_bus, :redis)

    redis_port = Keyword.get(redis_env, :port, "6369") |> String.to_integer
    redis_host = Keyword.get(redis_env, :host, "localhost")

    redix_workers = [
      worker(Redix, [[port: redis_port, host: redis_host, name: RedixConnection]])
    ]

    children = children ++ redix_workers

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ExMessageBus.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
