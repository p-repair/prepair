defmodule PrepairWeb.Api.Accounts.AccountsControllerTest do
  use PrepairWeb.ConnCase, async: true

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  setup [:create_and_set_api_key, :register_and_log_in_user]

  describe "GET /api/v1/users" do
    test "fetch the current user id",
         %{conn: conn, user: user} do
      conn =
        get(conn, ~p"/api/v1/users")

      assert json_response(conn, 200) == %{"data" => %{"id" => user.id}}
    end
  end
end
