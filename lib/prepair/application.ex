defmodule Prepair.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the repository
      Prepair.Repo,
      # Start the Telemetry supervisor
      PrepairWeb.Telemetry,
      # Start the async mailer task supervisor.
      {Task.Supervisor, name: Prepair.AsyncEmailSupervisor},
      # Start the PubSub system
      {Phoenix.PubSub, name: Prepair.PubSub},
      # Start Finch
      # {Finch, name: Prepair.Finch},
      # Start the Endpoint (http/https)
      PrepairWeb.Endpoint
      # Start a worker by calling: Prepair.Worker.start_link(arg)
      # {Prepair.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Prepair.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PrepairWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
