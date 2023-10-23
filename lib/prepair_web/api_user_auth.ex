defmodule PrepairWeb.ApiUserAuth do
  alias Prepair.Accounts

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
  Used for routes that require the user to be an admin.
  """
  def require_api_admin(conn, opts) do
    with conn <- require_authenticated_api_user(conn, opts),
         :admin <- conn.assigns.current_user.role do
      conn
    else
      _ ->
        conn
        |> put_status(:forbidden)
        |> put_view(PrepairWeb.ErrorJSON)
        |> render(:"403")
        |> halt()
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
