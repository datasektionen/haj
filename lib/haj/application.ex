defmodule Haj.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Haj.Repo,
      # Start the Telemetry supervisor
      HajWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Haj.PubSub},
      # Start the Endpoint (http/https)
      HajWeb.Endpoint,
      # Start the presence tracker (for online users)
      Haj.Presence
      # Start a worker by calling: Haj.Worker.start_link(arg)
      # {Haj.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Haj.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    HajWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
