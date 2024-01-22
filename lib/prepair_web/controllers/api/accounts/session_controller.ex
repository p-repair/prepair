defmodule PrepairWeb.Api.SessionController do
  use PrepairWeb, :controller

  alias PrepairWeb.ApiUserAuth

  action_fallback PrepairWeb.Api.FallbackController

  def create(conn, %{"email" => email, "password" => password}) do
    with {:ok, token} <- ApiUserAuth.create_user_token(email, password) do
      conn
      |> json(%{data: %{token: Base.encode64(token)}})
    end
  end

  def create(_conn, _) do
    {:error, :bad_request}
  end
end
