defmodule PrepairWeb.ContactControllerTest do
  use PrepairWeb.ConnCase, async: true

  ##############################################################################
  ########################## AUTHORIZATION - VISITORS ##########################
  ##############################################################################
  describe "Authorization - visitors" do
    ######################## WHAT VISITORS CAN DO ? ############################

    # Nothing

    ####################### WHAT VISITORS CANNOT DO ? ##########################

    @tag :contact_controller
    test "shows an error message and redirects to log in page if a visitor
    attempts to get this page",
         %{conn: conn} do
      conn = get(conn, ~p"/contacts")

      assert Phoenix.Flash.get(conn.assigns.flash, :error) ==
               "You must log in to access this page."

      assert redirected_to(conn) == ~p"/users/log_in"
    end
  end

  ##############################################################################
  ########################### AUTHORIZATION - USERS ############################
  ##############################################################################
  describe "Authorization - users" do
    ########################### WHAT USERS CAN DO ? ############################

    # Nothing

    ######################### WHAT USERS CANNOT DO ? ###########################

    @tag :contact_controller
    test "shows an error page if the current user is not admin",
         %{conn: conn} do
      %{conn: conn} = register_and_log_in_user(%{conn: conn})

      conn = get(conn, ~p"/contacts")
      response = html_response(conn, 403)

      assert response =~ "Forbidden"
    end
  end

  ##############################################################################
  ########################## FEATURES TESTS - ADMIN ############################
  ##############################################################################

  describe "GET /contacts" do
    setup [:register_and_log_in_user, :make_user_admin]
    @tag :contact_controller
    test "displays the list of contacts if the current user is admin",
         %{conn: conn} do
      conn = get(conn, ~p"/contacts")
      response = html_response(conn, 200)

      assert response =~ "Listing Contacts"
    end
  end

  # NOTE: We assume for now that we don’t do tests on contacts creation |
  # modification and deletion because it’s sending true requests to the
  # Mailerlite API. We test it manually.
end
