defmodule PrepairWeb.Api.GeneralTest do
  use PrepairWeb.ConnCase

  describe "status" do
    test "returns ok", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/status")
      assert json_response(conn, :ok)["data"] == %{"status" => "ok"}
    end
  end
end
