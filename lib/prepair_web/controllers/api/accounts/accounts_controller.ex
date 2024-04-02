defmodule PrepairWeb.Api.Accounts.AccountsController do
  use PrepairWeb, :controller

  action_fallback PrepairWeb.Api.FallbackController

  def fetch_api_user(conn, _params) do
    current_user = conn.assigns.current_user

    json(conn, %{data: %{uuid: current_user.uuid}})
  end
end
