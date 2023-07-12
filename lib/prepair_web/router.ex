defmodule PrepairWeb.Router do
  use PrepairWeb, :router

  import PrepairWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {PrepairWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PrepairWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/my-data", PageController, :my_data
    get "/delete-my-data", PageController, :delete_my_data
    post "/subscribe", PageController, :subscribe
  end

  scope "/", PrepairWeb do
    pipe_through [:browser, :require_authenticated_user]

    resources "/contacts", ContactController
  end

  # Other scopes may use custom stacks.
  # scope "/api", PrepairWeb do
  #   pipe_through :api
  # end

  ## Authentication routes

  scope "/", PrepairWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/users/log_in", UserSessionController, :new
    post "/users/log_in", UserSessionController, :create
  end

  scope "/", PrepairWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:prepair, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: PrepairWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end