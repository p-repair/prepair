defmodule PrepairWeb.UserUpdatePasswordLiveTest do
  use PrepairWeb.ConnCase

  alias Prepair.Accounts

  import Phoenix.LiveViewTest
  import Prepair.AccountsFixtures

  describe "Update password page" do
    @tag :update_password_live
    test "renders update password page", %{conn: conn} do
      {:ok, _lv, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/users/update_password")

      assert html =~ "Update your password"
    end

    @tag :update_password_live
    test "redirects if user is not logged in", %{conn: conn} do
      assert {:error, redirect} = live(conn, ~p"/users/update_password")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/log_in"
      assert %{"error" => "You must log in to access this page."} = flash
    end
  end

  describe "update password form" do
    setup [:register_and_log_in_user]

    @tag :update_password_live
    test "updates user password and redirects to home when updated with valid
    credentials",
         %{conn: conn, user: user, user_password: user_password} do
      new_password = valid_user_password()

      {:ok, lv, _html} = live(conn, ~p"/users/update_password")

      form =
        form(lv, "#update_password_form", %{
          "user" => %{
            "email" => user.email,
            "current_password" => user_password,
            "password" => new_password,
            "password_confirmation" => new_password
          }
        })

      render_submit(form)

      new_password_conn = follow_trigger_action(form, conn)

      assert redirected_to(new_password_conn) == ~p"/"

      assert get_session(new_password_conn, :user_token) !=
               get_session(conn, :user_token)

      assert Phoenix.Flash.get(new_password_conn.assigns.flash, :info) =~
               "Password updated successfully"

      assert Accounts.get_user_by_email_and_password(user.email, new_password)
    end

    @tag :update_password_live
    test "renders errors with invalid data (phx-change)", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/update_password")

      result =
        lv
        |> element("#update_password_form")
        |> render_change(%{
          "user" => %{
            "current_password" => "invalid",
            "password" => "short",
            "password_confirmation" => "does not match"
          }
        })

      assert result =~ "Update password"
      assert result =~ "should be at least 8 character(s)"
      assert result =~ "at least one digit or punctuation character"
      assert result =~ "at least one upper case character"
      assert result =~ "does not match password"
    end

    @tag :update_password_live
    test "renders errors with invalid data (phx-submit)", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/update_password")

      result =
        lv
        |> form("#update_password_form", %{
          "user" => %{
            "current_password" => "invalid",
            "password" => "short",
            "password_confirmation" => "does not match"
          }
        })
        |> render_submit()

      assert result =~ "Update password"
      assert result =~ "should be at least 8 character(s)"
      assert result =~ "at least one digit or punctuation character"
      assert result =~ "at least one upper case character"
      assert result =~ "does not match password"
    end
  end
end
