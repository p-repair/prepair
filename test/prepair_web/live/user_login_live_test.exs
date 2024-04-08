defmodule PrepairWeb.UserLoginLiveTest do
  use PrepairWeb.ConnCase

  import Phoenix.LiveViewTest
  import Prepair.AccountsFixtures

  describe "Log in page" do
    test "renders log in page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/users/log_in")

      assert html =~ "Log in"
    end

    @tag :gettext
    test "log in page is translated to the first language in 'accept-language'
  which match one of the locales defined for the application",
         %{conn: conn} do
      conn = conn |> set_language_to_de_then_fr()
      {:ok, _lv, html} = live(conn, ~p"/users/log_in")

      assert html =~ "Se connecter"
    end

    @tag :gettext
    test "log in page is not translated ('en' is the default locale) if none
  of the languages in 'accept-language' is part of the locales defined for
  the app",
         %{conn: conn} do
      conn = conn |> set_language_to_unknown()
      {:ok, _lv, html} = live(conn, ~p"/users/log_in")

      assert html =~ "Log in"
    end

    test "redirects if already logged in", %{conn: conn} do
      result =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/users/log_in")
        |> follow_redirect(conn, "/")

      assert {:ok, _conn} = result
    end
  end

  describe "user login" do
    test "redirects if user login with valid credentials", %{conn: conn} do
      password = valid_user_password()
      user = user_fixture(%{password: password})

      {:ok, lv, _html} = live(conn, ~p"/users/log_in")

      form =
        form(lv, "#login_form",
          user: %{email: user.email, password: password, remember_me: true}
        )

      conn = submit_form(form, conn)

      assert redirected_to(conn) == ~p"/"
    end

    test "redirects to login page with a flash error if there are no valid credentials",
         %{
           conn: conn
         } do
      {:ok, lv, _html} = live(conn, ~p"/users/log_in")

      form =
        form(lv, "#login_form",
          user: %{
            email: "test@email.com",
            password: "123456",
            remember_me: true
          }
        )

      conn = submit_form(form, conn)

      assert Phoenix.Flash.get(conn.assigns.flash, :error) ==
               "Invalid email or password"

      assert redirected_to(conn) == "/users/log_in"
    end
  end
end
