defmodule PrepairWeb.UserSessionController do
  use PrepairWeb, :controller

  alias Prepair.Accounts
  alias PrepairWeb.UserAuth

  def create(conn, params) do
    create(conn, params, dgettext("infos", "Welcome back!"))
  end

  defp create(conn, %{"user" => user_params}, info) do
    %{"email" => email, "password" => password} = user_params

    if user = Accounts.get_user_by_email_and_password(email, password) do
      conn
      |> put_flash(:info, info)
      |> UserAuth.log_in_user(user, user_params)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      conn
      |> put_flash(:error, dgettext("errors", "Invalid email or password"))
      |> put_flash(:email, String.slice(email, 0, 160))
      |> redirect(to: ~p"/users/log_in")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, dgettext("infos", "Logged out successfully."))
    |> UserAuth.log_out_user()
  end
end
