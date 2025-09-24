defmodule MyKemudahan.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      MyKemudahanWeb.Telemetry,
      MyKemudahan.Repo,
      {DNSCluster, query: Application.get_env(:myKemudahan, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: MyKemudahan.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: MyKemudahan.Finch},
      # Daily reminder scheduler
      MyKemudahan.Scheduler.DueReminder,
      # Start a worker by calling: MyKemudahan.Worker.start_link(arg)
      # {MyKemudahan.Worker, arg},
      # Start to serve requests, typically the last entry
      MyKemudahanWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MyKemudahan.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MyKemudahanWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
