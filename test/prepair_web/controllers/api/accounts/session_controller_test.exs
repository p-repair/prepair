defmodule PrepairWeb.Api.Accounts.SessionControllerTest do
  use PrepairWeb.ConnCase, async: true

  import Prepair.AccountsFixtures

  defp create_user(_) do
    user_password = valid_user_password()
    user = user_fixture(%{password: user_password})

    %{user: user, user_password: user_password}
  end

  setup [:create_and_set_api_key, :create_user]

  ##############################################################################
  ########################## VISITORS - AUTHORIZATION ##########################
  ##############################################################################

  ######################### WHAT VISITORS CAN DO ? #############################

  describe "POST /api/v1/users/log_in" do
    @tag :session_controller
    test "fetch a session token when valid credentials are given",
         %{conn: conn, user: user, user_password: user_password} do
      conn =
        post(conn, ~p"/api/v1/users/log_in", %{
          "email" => user.email,
          "password" => user_password
        })

      response = json_response(conn, :ok)

      assert %{"data" => %{"token" => _token, "user_id" => _user_id}} =
               response
    end

    @tag :session_controller
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

    @tag :session_controller
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

    @tag :session_controller
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
