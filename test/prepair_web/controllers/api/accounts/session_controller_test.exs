defmodule PrepairWeb.Api.Accounts.SessionControllerTest do
  use PrepairWeb.ConnCase, async: true

  import Prepair.AccountsFixtures

  setup do
    %{user: user_fixture()}
  end

  setup [:create_and_set_api_key]

  describe "POST /api/v1/users/log_in" do
    test "fetch a session token when valid credentials are given",
         %{conn: conn, user: user} do
      conn =
        post(conn, ~p"/api/v1/users/log_in", %{
          "email" => user.email,
          "password" => valid_user_password()
        })

      response = json_response(conn, :ok)
      assert %{"data" => %{"token" => _token}} = response
    end

    test "raises an error when invalid email is given",
         %{conn: conn} do
      conn =
        post(conn, ~p"/api/v1/users/log_in", %{
          "email" => "invalid_email",
          "password" => valid_user_password()
        })

      response = json_response(conn, :unauthorized)

      assert %{"errors" => [%{"details" => "Invalid username or password."}]} ==
               response
    end

    test "raises an error when invalid password is given",
         %{conn: conn, user: user} do
      conn =
        post(conn, ~p"/api/v1/users/log_in", %{
          "email" => user.email,
          "password" => "invalid_password"
        })

      response = json_response(conn, :unauthorized)

      assert %{"errors" => [%{"details" => "Invalid username or password."}]} ==
               response
    end

    test "raises an error when the request does not contain credentials",
         %{conn: conn} do
      conn =
        post(conn, ~p"/api/v1/users/log_in", %{
          "invalid_credentials" => "invalid_credentials"
        })

      response = json_response(conn, :bad_request)

      assert %{"errors" => [%{"details" => "Bad request."}]} == response
    end
  end
end
