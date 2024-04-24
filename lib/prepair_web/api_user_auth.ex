defmodule PrepairWeb.ApiUserAuth do
  alias Prepair.Accounts
  alias Prepair.Profiles

  import Plug.Conn
  import Phoenix.Controller

  def create_user_token(email, password) do
    user = Accounts.get_user_by_email_and_password(email, password)

    unless is_nil(user) do
      token = Accounts.generate_user_session_token(user)
      {:ok, token}
    else
      {:error, :invalid_credentials}
    end
  end

  def fetch_api_user(conn, _opts) do
    with {:ok, token} <- get_user_token(conn),
         user <- Accounts.get_user_by_session_token(token) do
      assign(conn, :current_user, user)
    else
      _ -> conn
    end
  end

  @doc """
  Used for routes that require the user to be authenticated.

  If you want to enforce the user email is confirmed before
  they use the application at all, here would be a good place.
  """
  def require_authenticated_api_user(conn, _opts) do
    unless is_nil(conn.assigns[:current_user]) do
      conn
    else
      conn
      |> put_status(:unauthorized)
      |> put_view(PrepairWeb.ErrorJSON)
      |> render(:"401")
      # Stop any downstream transformations.
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
  def require_api_self_or_admin(conn, _opts) do
    conn = require_authenticated_api_user(conn, [])

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

  defp is_self_user?(conn) do
    current_user = conn.assigns.current_user

    if current_user.id == conn.path_params["id"] or
         current_user.id == get_profile_id_from_request(conn) do
      conn
    else
      conn
      # TODO: enhance error pages
      |> put_status(:forbidden)
      |> put_view(PrepairWeb.ErrorJSON)
      |> render(:"403")
      |> halt()
    end
  end

  defp get_profile_id_from_request(conn) do
    method = conn.method
    context = conn.path_info |> Enum.at(2)
    schema = conn.path_info |> Enum.at(3)

    profile_id =
      case [method, context, schema] do
        [_, "profiles", "profiles"] ->
          conn.path_params["id"]

        ["POST", "profiles", "ownerships"] ->
          conn.params["profile_id"]

        [_, "profiles", "ownerships"] ->
          Profiles.get_ownership!(conn.path_params["id"]).profile_id
      end

    profile_id
  end

  @doc """
  Used for routes that require the user to be an admin.
  """
  # NOTE: J’ai dû changer la fonction car
  # with conn <- require_authenticated_user(conn, opts) retourne toujours conn
  # sinon il faudrait modifier son retour en {:ok, conn} | {:error, conn}
  # mais nous devons voir ça ensemble
  def require_api_admin(conn, _opts) do
    conn = require_authenticated_api_user(conn, [])

    if conn.assigns[:current_user] != nil do
      case conn.assigns.current_user.role do
        :admin ->
          conn

        _ ->
          conn
          |> put_status(:forbidden)
          |> put_view(PrepairWeb.ErrorJSON)
          |> render(:"403")
          |> halt()
      end
    else
      conn
    end
  end

  defp get_user_token(conn) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, token} <- Base.decode64(token) do
      {:ok, token}
    else
      _ -> {:error, :no_token}
    end
  end
end
