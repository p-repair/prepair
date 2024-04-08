defmodule PrepairWeb.Api.Accounts.UserControllerTest do
  use PrepairWeb.ConnCase, async: true

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "GET /api/v1/users" do
    setup [:create_and_set_api_key, :register_and_log_in_user]

    @tag :user_controller
    test "fetch the current user uuid",
         %{conn: conn, user: user} do
      conn =
        get(conn, ~p"/api/v1/users")

      assert json_response(conn, 200) == %{"data" => %{"uuid" => user.uuid}}
    end
  end
end
