defmodule PrepairWeb.Api.GeneralTest do
  use PrepairWeb.ConnCase

  ##############################################################################
  ########################## VISITORS - AUTHORIZATION ##########################
  ##############################################################################

  ######################### WHAT VISITORS CAN DO ? #############################

  describe "status" do
    setup [:create_and_set_api_key]

    @tag :general_test
    test "returns ok", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/status")
      assert json_response(conn, :ok)["data"] == %{"status" => "ok"}
    end

    @tag :general_test
    @tag :gettext
    test "locale is set from request headers in API calls", %{conn: conn} do
      conn = conn |> put_req_header("accept-language", "fr")
      get(conn, ~p"/api/v1/status")

      assert Gettext.get_locale() == "fr"
    end
  end

  @tag :general_test
  test "API requests need an API key", %{conn: conn} do
    conn = get(conn, ~p"/api/v1/status")

    assert json_response(conn, :unauthorized)["errors"] == [
             %{"detail" => "missing API key"}
           ]
  end

  @tag :general_test
  @tag :gettext
  test "locale is set from request headers in API calls even without API key",
       %{conn: conn} do
    conn = conn |> put_req_header("accept-language", "fr")
    get(conn, ~p"/api/v1/status")

    assert Gettext.get_locale() == "fr"
  end

  @tag :general_test
  @tag :gettext
  test "error messages are translated to the first language in 'accept-language'
  which match one of the locales defined for the application",
       %{conn: conn} do
    conn =
      conn
      |> put_req_header(
        "accept-language",
        "de-DE,fr-FR;q=0.8,en;q=0.5,es-ES;q=0.3"
      )

    conn = get(conn, ~p"/api/v1/status")

    assert json_response(conn, :unauthorized)["errors"] == [
             %{"detail" => "clé API manquante"}
           ]
  end

  @tag :general_test
  @tag :gettext
  test "error messages are not translated ('en' is the default locale) if none
  of the languages in 'accept-language' is part of the locales defined for
  the app",
       %{conn: conn} do
    conn =
      conn
      |> put_req_header(
        "accept-language",
        "de-DE,ru-RU;q=0.8,es-ES;q=0.3"
      )

    conn = get(conn, ~p"/api/v1/status")

    assert json_response(conn, :unauthorized)["errors"] == [
             %{"detail" => "missing API key"}
           ]
  end

  @tag :general_test
  @tag :gettext
  test "error messages are not translated ('en' is the default locale) if
  'accept-language' is not set in the headers",
       %{conn: conn} do
    conn = get(conn, ~p"/api/v1/status")

    assert json_response(conn, :unauthorized)["errors"] == [
             %{"detail" => "missing API key"}
           ]
  end
end
