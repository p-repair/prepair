defmodule PrepairWeb.Api.GeneralTest do
  use PrepairWeb.ConnCase

  describe "status" do
    setup [:create_and_set_api_key]

    test "returns ok", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/status")
      assert json_response(conn, :ok)["data"] == %{"status" => "ok"}
    end
  end

  test "API requests need an API key", %{conn: conn} do
    conn = get(conn, ~p"/api/v1/status")

    assert json_response(conn, :unauthorized)["errors"] == [
             %{"detail" => "missing API key"}
           ]
  end
end
