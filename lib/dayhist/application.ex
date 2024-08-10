defmodule Dayhist.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      DayhistWeb.Telemetry,
      Dayhist.Repo,
      {DNSCluster, query: Application.get_env(:dayhist, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Dayhist.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Dayhist.Finch},
      # Start a worker by calling: Dayhist.Worker.start_link(arg)
      # {Dayhist.Worker, arg},
      # Start to serve requests, typically the last entry
      Dayhist.Spotify.Supervisor,
      DayhistWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Dayhist.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    DayhistWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
