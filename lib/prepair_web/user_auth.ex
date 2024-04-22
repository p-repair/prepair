defmodule PrepairWeb.UserAuth do
  use PrepairWeb, :verified_routes

  import Plug.Conn
  import Phoenix.Controller
  import PrepairWeb.Gettext

  alias Prepair.Accounts

  # Make the remember me cookie valid for 60 days.
  # If you want bump or reduce this value, also change
  # the token expiry itself in UserToken.
  @max_age 60 * 60 * 24 * 60
  @remember_me_cookie "_prepair_web_user_remember_me"
  @remember_me_options [sign: true, max_age: @max_age, same_site: "Lax"]

  @doc """
  Logs the user in.

  It renews the session ID and clears the whole session
  to avoid fixation attacks. See the renew_session
  function to customize this behaviour.

  It also sets a `:live_socket_id` key in the session,
  so LiveView sessions are identified and automatically
  disconnected on log out. The line can be safely removed
  if you are not using LiveView.
  """
  def log_in_user(conn, user, params \\ %{}) do
    token = Accounts.generate_user_session_token(user)
    user_return_to = get_session(conn, :user_return_to)

    conn
    |> renew_session()
    |> put_token_in_session(token)
    |> maybe_write_remember_me_cookie(token, params)
    |> redirect(to: user_return_to || signed_in_path(conn))
  end

  defp maybe_write_remember_me_cookie(conn, token, %{"remember_me" => "true"}) do
    put_resp_cookie(conn, @remember_me_cookie, token, @remember_me_options)
  end

  defp maybe_write_remember_me_cookie(conn, _token, _params) do
    conn
  end

  # This function renews the session ID and erases the whole
  # session to avoid fixation attacks. If there is any data
  # in the session you may want to preserve after log in/log out,
  # you must explicitly fetch the session data before clearing
  # and then immediately set it after clearing, for example:
  #
  #     defp renew_session(conn) do
  #       preferred_locale = get_session(conn, :preferred_locale)
  #
  #       conn
  #       |> configure_session(renew: true)
  #       |> clear_session()
  #       |> put_session(:preferred_locale, preferred_locale)
  #     end
  #
  defp renew_session(conn) do
    conn
    |> configure_session(renew: true)
    |> clear_session()
  end

  @doc """
  Logs the user out.

  It clears all session data for safety. See renew_session.
  """
  def log_out_user(conn) do
    user_token = get_session(conn, :user_token)
    user_token && Accounts.delete_user_session_token(user_token)

    if live_socket_id = get_session(conn, :live_socket_id) do
      PrepairWeb.Endpoint.broadcast(live_socket_id, "disconnect", %{})
    end

    conn
    |> renew_session()
    |> delete_resp_cookie(@remember_me_cookie)
    |> redirect(to: ~p"/")
  end

  @doc """
  Authenticates the user by looking into the session
  and remember me token.
  """
  def fetch_current_user(conn, _opts) do
    {user_token, conn} = ensure_user_token(conn)
    user = user_token && Accounts.get_user_by_session_token(user_token)
    assign(conn, :current_user, user)
  end

  defp ensure_user_token(conn) do
    if token = get_session(conn, :user_token) do
      {token, conn}
    else
      conn = fetch_cookies(conn, signed: [@remember_me_cookie])

      if token = conn.cookies[@remember_me_cookie] do
        {token, put_token_in_session(conn, token)}
      else
        {nil, conn}
      end
    end
  end

  @doc """
  Handles mounting and authenticating the current_user in LiveViews.

  ## `on_mount` arguments

    * `:mount_current_user` - Assigns current_user
      to socket assigns based on user_token, or nil if
      there's no user_token or no matching user.

    * `:ensure_authenticated` - Authenticates the user from the session,
      and assigns the current_user to socket assigns based
      on user_token.
      Redirects to login page if there's no logged user.

    * `:redirect_if_user_is_authenticated` - Authenticates the user from the session.
      Redirects to signed_in_path if there's a logged user.

  ## Examples

  Use the `on_mount` lifecycle macro in LiveViews to mount or authenticate
  the current_user:

      defmodule PrepairWeb.PageLive do
        use PrepairWeb, :live_view

        on_mount {PrepairWeb.UserAuth, :mount_current_user}
        ...
      end

  Or use the `live_session` of your router to invoke the on_mount callback:

      live_session :authenticated, on_mount: [{PrepairWeb.UserAuth, :ensure_authenticated}] do
        live "/profile", ProfileLive, :index
      end
  """
  def on_mount(:mount_current_user, _params, session, socket) do
    {:cont, mount_current_user(socket, session)}
  end

  def on_mount(:ensure_authenticated, _params, session, socket) do
    socket = mount_current_user(socket, session)

    if socket.assigns.current_user do
      {:cont, socket}
    else
      socket =
        socket
        |> Phoenix.LiveView.put_flash(
          :error,
          dgettext("errors", "You must log in to access this page.")
        )
        |> Phoenix.LiveView.redirect(to: ~p"/users/log_in")

      {:halt, socket}
    end
  end

  def on_mount(:ensure_current_user_access_self_data, params, session, socket) do
    socket = mount_current_user(socket, session)

    if socket.assigns.current_user.uuid == params["uuid"] do
      {:cont, socket}
    else
      socket =
        socket
        |> Phoenix.LiveView.put_flash(
          :error,
          dgettext("errors", "You are not allowed to access other users
            private data.")
        )

        # TODO: Error page instead?
        |> Phoenix.LiveView.redirect(to: ~p"/")

      {:halt, socket}
    end
  end

  def on_mount(:ensure_is_admin, params, session, socket) do
    with {:cont, socket} <-
           on_mount(:ensure_authenticated, params, session, socket),
         :admin <- socket.assigns.current_user.role do
      {:cont, socket}
    else
      _ ->
        socket =
          socket
          |> Phoenix.LiveView.put_flash(
            :error,
            dgettext("errors", "You must be admin to access this page.")
          )
          # TODO: Error page instead?
          |> Phoenix.LiveView.redirect(to: ~p"/users/log_in")

        {:halt, socket}
    end
  end

  def on_mount(:redirect_if_user_is_authenticated, _params, session, socket) do
    socket = mount_current_user(socket, session)

    if socket.assigns.current_user do
      {:halt, Phoenix.LiveView.redirect(socket, to: signed_in_path(socket))}
    else
      {:cont, socket}
    end
  end

  defp mount_current_user(socket, session) do
    Phoenix.Component.assign_new(socket, :current_user, fn ->
      if user_token = session["user_token"] do
        Accounts.get_user_by_session_token(user_token)
      end
    end)
  end

  @doc """
  Used for routes that require the user to not be authenticated.
  """
  def redirect_if_user_is_authenticated(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
      |> redirect(to: signed_in_path(conn))
      |> halt()
    else
      conn
    end
  end

  @doc """
  Used for routes that require the user to be authenticated.

  If you want to enforce the user email is confirmed before
  they use the application at all, here would be a good place.
  """
  def require_authenticated_user(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(
        :error,
        dgettext("errors", "You must log in to access this page.")
      )
      |> maybe_store_return_to()
      |> redirect(to: ~p"/users/log_in")
      |> halt()
    end
  end

  @doc """
  Used for routes which gives access only to self data.
  Admins still have access too.
  """
  # TODO: refactor require_authenticated_user to return {:ok, conn} | {:error, conn}
  # TODO: refactor require_admin to return {:ok, conn} | {:error, conn}
  # TODO: refactor require_self_or_admin to return {:ok, conn} | {:error, conn}
  def require_self_or_admin(conn, _opts) do
    conn = require_authenticated_user(conn, [])

    if conn.assigns[:current_user] != nil do
      case conn.assigns.current_user.role do
        :admin ->
          conn

        _ ->
          is_self_user?(conn)
      end
    else
      conn
    end
  end

  # TODO: to make this function universal, we should add an 'or' clause to the
  # if statement, get the object from "uuid" in params, and search for an
  # equality between current_user.uuid and object.profile_uuid (that would be
  # necessary for ownerships, for instance). Just like it has been done on
  # the ApiUserAuth module.
  defp is_self_user?(conn) do
    if conn.assigns.current_user.uuid == conn.path_params["uuid"] do
      conn
    else
      conn
      # TODO: enhance error pages
      |> put_status(:forbidden)
      |> put_view(PrepairWeb.ErrorHTML)
      |> render(:"403")
      |> halt()
    end
  end

  @doc """
  Used for routes that require the user to be an admin.
  """
  # NOTE: J’ai dû changer la fonction car
  # with conn <- require_authenticated_user(conn, opts) retourne toujours conn
  # sinon il faudrait modifier son retour en {:ok, conn} | {:error, conn}
  # mais nous devons voir ça ensemble
  def require_admin(conn, _opts) do
    conn = require_authenticated_user(conn, [])

    if conn.assigns[:current_user] != nil do
      case conn.assigns.current_user.role do
        :admin ->
          conn

        _ ->
          conn

          # # TODO: Proposition
          # |> put_flash(
          #   :error,
          #   dgettext("errors", "You must be admin to access this page.")
          # )
          # |> maybe_store_return_to()
          # |> redirect(to: ~p"/")
          # |> halt()

          |> put_status(:forbidden)
          |> put_view(PrepairWeb.ErrorHTML)
          |> render(:"403")
          |> halt()
      end
    else
      conn
    end
  end

  def require_self_and_do(scope, socket, params, action) do
    data_owner =
      case scope do
        :ownership ->
          Prepair.Profiles.get_ownership!(params["uuid"]).profile_uuid
      end

    current_user = socket.assigns.current_user

    if current_user.uuid == data_owner or
         is_admin?(current_user) do
      action.()
    else
      socket =
        socket
        |> Phoenix.LiveView.put_flash(
          :error,
          dgettext("errors", "You are not allowed to access other users
            private data.")
        )
        |> Phoenix.LiveView.redirect(to: ~p"/")

      socket
    end
  end

  defp is_admin?(user) do
    if user.role == :admin, do: true, else: false
  end

  @doc """
  Ensures the `socket` belongs to an admin and performs `action`.

  This function can be used in LiveView event handlers to wrap the action with
  an authorisation check. If the socket belongs to an authenticated admin, the
  action is performed, otherwise a flash is put with an error message and the
  page reloaded.
  """
  def require_admin_and_do(socket, action) do
    if socket.assigns.current_user.role == :admin do
      action.()
    else
      socket =
        socket
        |> Phoenix.LiveView.put_flash(
          :error,
          dgettext("errors", "You must be admin to perform this action.")
        )

      {:noreply, socket}
    end
  end

  defp put_token_in_session(conn, token) do
    conn
    |> put_session(:user_token, token)
    |> put_session(
      :live_socket_id,
      "users_sessions:#{Base.url_encode64(token)}"
    )
  end

  defp maybe_store_return_to(%{method: "GET"} = conn) do
    put_session(conn, :user_return_to, current_path(conn))
  end

  defp maybe_store_return_to(conn), do: conn

  defp signed_in_path(_conn), do: ~p"/"
end
