defmodule PrepairWeb.Api.SessionController do
  use PrepairWeb, :controller

  alias Prepair.Accounts
  alias PrepairWeb.ApiUserAuth

  action_fallback PrepairWeb.Api.FallbackController

  def create(conn, %{"email" => email, "password" => password}) do
    with {:ok, token} <- ApiUserAuth.create_user_token(email, password),
         user <- Accounts.get_user_by_email_and_password(email, password) do
      conn
      |> json(%{data: %{token: Base.encode64(token), user_uuid: user.uuid}})
    end
  end

  def create(_conn, _) do
    {:error, :bad_request}
  end
end
