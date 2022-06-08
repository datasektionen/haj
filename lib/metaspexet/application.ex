defmodule Metaspexet.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Metaspexet.Repo,
      # Start the Telemetry supervisor
      MetaspexetWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Metaspexet.PubSub},
      # Start the Endpoint (http/https)
      MetaspexetWeb.Endpoint
      # Start a worker by calling: Metaspexet.Worker.start_link(arg)
      # {Metaspexet.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Metaspexet.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MetaspexetWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
