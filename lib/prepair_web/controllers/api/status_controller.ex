defmodule PrepairWeb.Api.StatusController do
  use PrepairWeb, :controller

  def status(conn, _params) do
    json(conn, %{data: %{status: "ok"}})
  end
end
