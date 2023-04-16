defmodule PrepairLandingPage.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the repository
      PrepairLandingPage.Repo,
      # Start the Telemetry supervisor
      PrepairLandingPageWeb.Telemetry,
      # Start the async mailer task supervisor.
      {Task.Supervisor, name: PrepairLandingPage.AsyncEmailSupervisor},
      # Start the PubSub system
      {Phoenix.PubSub, name: PrepairLandingPage.PubSub},
      # Start Finch
      # {Finch, name: PrepairLandingPage.Finch},
      # Start the Endpoint (http/https)
      PrepairLandingPageWeb.Endpoint
      # Start a worker by calling: PrepairLandingPage.Worker.start_link(arg)
      # {PrepairLandingPage.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PrepairLandingPage.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PrepairLandingPageWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
