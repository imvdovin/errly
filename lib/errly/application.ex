defmodule Errly.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ErrlyWeb.Telemetry,
      Errly.Repo,
      {DNSCluster, query: Application.get_env(:errly, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Errly.PubSub},
      # Start a worker by calling: Errly.Worker.start_link(arg)
      # {Errly.Worker, arg},
      # Start to serve requests, typically the last entry
      ErrlyWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Errly.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ErrlyWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
