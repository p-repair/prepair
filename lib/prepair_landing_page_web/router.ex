defmodule PrepairLandingPageWeb.Router do
  use PrepairLandingPageWeb, :router

  import PrepairLandingPageWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {PrepairLandingPageWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PrepairLandingPageWeb do
    pipe_through :browser

    get "/", PageController, :home
    post "/subscribe", PageController, :subscribe
    resources "/contacts", ContactController
  end

  scope "/", PrepairLandingPageWeb do
    pipe_through [:browser, :require_authenticated_user]
  end

  # Other scopes may use custom stacks.
  # scope "/api", PrepairLandingPageWeb do
  #   pipe_through :api
  # end

  ## Authentication routes

  scope "/", PrepairLandingPageWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/users/log_in", UserSessionController, :new
    post "/users/log_in", UserSessionController, :create
  end

  scope "/", PrepairLandingPageWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:prepair_landing_page, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: PrepairLandingPageWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
