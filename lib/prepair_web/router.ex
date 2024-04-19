defmodule PrepairWeb.Router do
  use PrepairWeb, :router

  import PrepairWeb.ApiAuth
  import PrepairWeb.UserAuth
  import PrepairWeb.ApiUserAuth
  import PrepairWeb.Localisation
  import PrepairWeb.Api.Localisation

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {PrepairWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
    plug :set_web_localisation
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :set_api_localisation
    plug :require_valid_api_key
    plug :fetch_api_user
  end

  ##############################################################################
  ############################### WEB INTERFACES ###############################
  ##############################################################################

  ################################## Everyone ##################################

  scope "/", PrepairWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/my-data", PageController, :my_data
    get "/delete-my-data", PageController, :delete_my_data
    post "/subscribe", PageController, :subscribe
  end

  ################################# All users ##################################

  scope "/", PrepairWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{PrepairWeb.UserAuth, :ensure_authenticated}] do
      live "/users/update_password", UserUpdatePasswordLive, :new
      live "/users/update_email", UserUpdateEmailLive, :new

      live "/manufacturers", ManufacturerLive.Index, :index
      live "/manufacturers/new", ManufacturerLive.Index, :new

      live "/manufacturers/:uuid", ManufacturerLive.Show, :show

      live "/categories", CategoryLive.Index, :index
      live "/categories/new", CategoryLive.Index, :new

      live "/categories/:uuid", CategoryLive.Show, :show

      live "/products", ProductLive.Index, :index
      live "/products/new", ProductLive.Index, :new

      live "/products/:uuid", ProductLive.Show, :show

      live "/parts", PartLive.Index, :index
      live "/parts/new", PartLive.Index, :new

      live "/parts/:uuid", PartLive.Show, :show

      live "/profiles/ownerships/by_profile/:uuid",
           ProfileLive.OwnershipIndex,
           :index

      live "/ownerships/new", OwnershipLive.Index, :new

      ## NOTE: Self only for *ownerships* below (managed at liveview level).
      live "/ownerships/:uuid", OwnershipLive.Show, :show
      live "/ownerships/:uuid/edit", OwnershipLive.Index, :edit
      live "/ownerships/:uuid/show/edit", OwnershipLive.Show, :edit

      live "/notification_templates", NotificationTemplateLive.Index, :index
      live "/notification_templates/new", NotificationTemplateLive.Index, :new

      live "/notification_templates/:uuid", NotificationTemplateLive.Show, :show
    end
  end

  ################################# Self only ##################################

  ## TODO: Maybe delete this scope to handle this case at liveview level like for
  ## ownerships?
  scope "/", PrepairWeb do
    pipe_through [:browser, :require_self_or_admin]

    live_session :require_self_or_admin,
      on_mount: [{PrepairWeb.UserAuth, :ensure_current_user_access_self_data}] do
      live "/profiles/:uuid", ProfileLive.Show, :show
      live "/profiles/:uuid/edit", ProfileLive.Index, :edit

      live "/profiles/:uuid/show/edit", ProfileLive.Show, :edit
    end
  end

  ################################ Admins only #################################

  scope "/", PrepairWeb do
    pipe_through [:browser, :require_admin]

    resources "/contacts", ContactController

    live_session :require_admin,
      on_mount: [{PrepairWeb.UserAuth, :ensure_is_admin}] do
      live "/manufacturers/:uuid/edit", ManufacturerLive.Index, :edit
      live "/manufacturers/:uuid/show/edit", ManufacturerLive.Show, :edit

      live "/categories/:uuid/edit", CategoryLive.Index, :edit
      live "/categories/:uuid/show/edit", CategoryLive.Show, :edit

      live "/products/:uuid/edit", ProductLive.Index, :edit
      live "/products/:uuid/show/edit", ProductLive.Show, :edit

      live "/parts/:uuid/edit", PartLive.Index, :edit
      live "/parts/:uuid/show/edit", PartLive.Show, :edit

      live "/profiles", ProfileLive.Index, :index

      live "/ownerships", OwnershipLive.Index, :index

      live "/notification_templates/:uuid/edit",
           NotificationTemplateLive.Index,
           :edit

      live "/notification_templates/:uuid/show/edit",
           NotificationTemplateLive.Show,
           :edit
    end
  end

  ##############################################################################
  ############################### AUTHENTICATION ###############################
  ##############################################################################

  ######################## Authentication routes (web) #########################

  scope "/", PrepairWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{PrepairWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", PrepairWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
  end

  ######################## Authentication routes (api) #########################

  scope "/api/v1", PrepairWeb do
    pipe_through [:api]

    get "/status", Api.StatusController, :status

    post "/users/register", Api.Accounts.UserController, :create

    post "/users/log_in", Api.SessionController, :create
  end

  ##############################################################################
  ############################### API INTERFACES ###############################
  ##############################################################################

  scope "/api/v1", PrepairWeb do
    pipe_through [:api, :require_authenticated_api_user]

    get "/users", Api.Accounts.UserController, :fetch_api_user

    put "/users/update_password",
        Api.Accounts.UserController,
        :update_password

    put "/users/update_email", Api.Accounts.UserController, :update_email

    resources "/products/categories", Api.Products.CategoryController,
      except: [:new, :edit],
      param: "uuid"

    resources "/products/manufacturers", Api.Products.ManufacturerController,
      except: [:new, :edit],
      param: "uuid"

    resources "/products/products", Api.Products.ProductController,
      except: [:new, :edit],
      param: "uuid"

    resources "/products/parts", Api.Products.PartController,
      except: [:new, :edit],
      param: "uuid"

    resources "/profiles/profile", Api.Profiles.ProfileController,
      only: [:index, :show, :update],
      param: "uuid"

    get "/profiles/ownerships/by_profile/:uuid",
        Api.Profiles.OwnershipController,
        :index_by_profile

    resources "/profiles/ownerships", Api.Profiles.OwnershipController,
      except: [:index, :new, :edit],
      param: "uuid"
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
