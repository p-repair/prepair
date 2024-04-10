defmodule PrepairWeb.UserRegisterLiveTest do
  use PrepairWeb.ConnCase

  import Phoenix.LiveViewTest
  import Prepair.AccountsFixtures
  import Prepair.ProfilesFixtures

  describe "Register user page" do
    @tag :register_user_live
    test "renders register user page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/users/register")

      assert html =~ "Register for an account"
    end

    test "redirects if user is logged in", %{conn: conn} do
      result =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/users/register")
        |> follow_redirect(conn, "/")

      assert {:ok, _conn} = result
    end
  end

  describe "register user form" do
    @tag :register_user_live
    test "register user and redirects to home when form is validated with valid
    attributes (phx-submit)",
         %{conn: conn} do
      username = unique_username()
      email = unique_user_email()
      password = valid_user_password()

      {:ok, lv, _html} = live(conn, ~p"/users/register")

      form =
        form(lv, "#registration_form", %{
          "user" => %{
            "username" => username,
            "email" => email,
            "password" => password,
            "password_confirmation" => password,
            "people_in_household" => 1,
            "newsletter" => true
          }
        })

      render_submit(form)

      registered_user_con = follow_trigger_action(form, conn)
      assert redirected_to(registered_user_con) == ~p"/"
      assert _session = get_session(registered_user_con, :user_token)
    end

    @tag :register_user_live
    test "renders errors for invalid data (phx-change)", %{conn: conn} do
      existing_profile = profile_fixture()

      {:ok, lv, _html} = live(conn, ~p"/users/register")

      result =
        lv
        |> element("#registration_form")
        |> render_change(
          user: %{
            "username" => existing_profile.username,
            "email" => "with spaces",
            "password" => "short",
            "password_confirmation" => "does not match"
          }
        )

      assert result =~ "Register"
      assert result =~ "has already been taken"
      assert result =~ "must have the @ sign and no spaces"
      assert result =~ "at least one digit or punctuation character"
      assert result =~ "at least one upper case character"
      assert result =~ "should be at least 8 character"
      assert result =~ "does not match"
    end

    @tag :register_user_live
    test "renders errors for duplicated username (phx-change)", %{conn: conn} do
      existing_profile = profile_fixture()

      {:ok, lv, _html} = live(conn, ~p"/users/register")

      result =
        lv
        |> element("#registration_form")
        |> render_change(
          user: %{
            "username" => existing_profile.username
          }
        )

      assert result =~ "has already been taken"
    end

    @tag :register_user_live
    test "renders errors for duplicated email (phx-change)", %{conn: conn} do
      existing_user = user_fixture()

      {:ok, lv, _html} = live(conn, ~p"/users/register")

      result =
        lv
        |> element("#registration_form")
        |> render_change(
          user: %{
            "email" => existing_user.email
          }
        )

      assert result =~ "has already been taken"
    end
  end

  describe "registration navigation" do
    @tag :register_user_live
    test "redirects to login page when the Log in button is clicked", %{
      conn: conn
    } do
      {:ok, lv, _html} = live(conn, ~p"/users/register")

      {:ok, _login_live, login_html} =
        lv
        |> element(~s|main a:fl-contains("Sign in")|)
        |> render_click()
        |> follow_redirect(conn, ~p"/users/log_in")

      assert login_html =~ "Log in"
    end
  end
end
