defmodule PrepairWeb.PageControllerTest do
  use PrepairWeb.ConnCase, async: true

  ##############################################################################
  ########################## AUTHORIZATION - VISITORS ##########################
  ##############################################################################

  ######################## WHAT VISITORS CAN DO ? ############################

  describe "GET /" do
    @tag :page_controller
    test "displays home page for everyone (no need to be registered)",
         %{conn: conn} do
      conn = get(conn, ~p"/")

      response = html_response(conn, 200)

      assert response =~ "(p)repair newsletter"
    end
  end

  describe "GET /my-data" do
    @tag :page_controller
    test "displays my-data page for everyone (no need to be registered)",
         %{conn: conn} do
      conn = get(conn, ~p"/my-data")

      response = html_response(conn, 200)

      assert response =~ "Gestion des données utilisateurs"
    end
  end

  describe "GET /delete-my-data" do
    @tag :page_controller
    test "displays delete-my-data page for everyone (no need to be registered)",
         %{conn: conn} do
      conn = get(conn, ~p"/delete-my-data")

      response = html_response(conn, 200)

      assert response =~ "Suppression d’un compte et des données associées"
    end

    ####################### WHAT VISITORS CANNOT DO ? ##########################

    # Nothing
  end

  ##############################################################################
  ########################### AUTHORIZATION - USERS ############################
  ##############################################################################

  ########################### WHAT USERS CAN DO ? ############################

  # All the same as visitors.

  ######################### WHAT USERS CANNOT DO ? ###########################

  # Nothing

  ##############################################################################
  ########################## FEATURES TESTS - ADMIN ############################
  ##############################################################################

  # All the same as visitors.

  # NOTE: We assume for now that we don’t do tests on subscribe (= because it’s
  # sending true requests to the Mailerlite API. We test it manually.
end
