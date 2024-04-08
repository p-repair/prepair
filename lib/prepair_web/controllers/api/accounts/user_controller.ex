defmodule PrepairWeb.Api.Accounts.UserController do
  use PrepairWeb, :controller

  alias PrepairWeb.Api.SessionController
  alias Prepair.Accounts
  alias Prepair.Accounts.User

  action_fallback PrepairWeb.Api.FallbackController

  def fetch_api_user(conn, _params) do
    current_user = conn.assigns.current_user

    json(conn, %{data: %{uuid: current_user.uuid}})
  end

  def create(conn, %{"registration" => params}) do
    with {:ok, %User{} = _user} <-
           Accounts.register_user(params) do
      SessionController.create(conn, %{
        "email" => params["email"],
        "password" => params["password"]
      })
    end
  end

  @doc """
  Updates password, when current password and new password are given and are
  both valid.
  """
  def update_password(conn, %{
        "user" => %{
          "password" => current_password,
          "new_password" => new_password,
          "new_password_confirmation" => new_password_confirmation
        }
      }) do
    with {:ok, updated_user} <-
           Accounts.update_user_password(
             conn.assigns.current_user,
             current_password,
             %{
               password: new_password,
               password_confirmation: new_password_confirmation
             }
           ) do
      render(conn, :show, user: updated_user)
    end
  end

  @doc """
  Updates email when current password and new email are given and are both valid.
  """
  def update_email(conn, %{
        "user" => %{
          "password" => password,
          "new_email" => new_email,
          "new_email_confirmation" => new_email_confirmation
        }
      }) do
    with {:ok, updated_user} <-
           Accounts.update_user_email_basic(
             conn.assigns.current_user,
             password,
             %{email: new_email, email_confirmation: new_email_confirmation}
           ) do
      render(conn, :show, user: updated_user)
    end
  end
end
