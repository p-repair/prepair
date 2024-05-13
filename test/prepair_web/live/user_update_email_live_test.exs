defmodule PrepairWeb.UserUpdateEmailLiveTest do
  use PrepairWeb.ConnCase

  alias Prepair.LegacyContexts.Accounts

  import Phoenix.LiveViewTest
  import Prepair.LegacyContexts.AccountsFixtures

  describe "Update email page" do
    @tag :update_email_live
    test "renders update email page", %{conn: conn} do
      {:ok, _lv, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/users/update_email")

      assert html =~ "Update your email"
    end

    @tag :update_email_live
    test "redirects if user is not logged in", %{conn: conn} do
      assert {:error, redirect} = live(conn, ~p"/users/update_email")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/log_in"
      assert %{"error" => "You must log in to access this page."} = flash
    end
  end

  describe "update email form" do
    setup [:register_and_log_in_user]

    @tag :update_email_live
    test "updates user email and redirects to home when updated with valid
    credentials",
         %{conn: conn, user_password: user_password} do
      new_email = unique_user_email()

      {:ok, lv, _html} = live(conn, ~p"/users/update_email")

      form =
        form(lv, "#update_email_form", %{
          "user" => %{
            "current_password" => user_password,
            "email" => new_email,
            "email_confirmation" => new_email
          }
        })

      render_submit = render_submit(form)

      {:error, {:live_redirect, %{kind: kind, to: path, flash: _flash}}} =
        render_submit

      assert kind == :push
      assert path == ~p"/"

      assert get_session(conn, :user_token)
      assert Accounts.get_user_by_email_and_password(new_email, user_password)
    end

    @tag :update_email_live
    test "renders errors with invalid data (phx-change)", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/update_email")

      result =
        lv
        |> element("#update_email_form")
        |> render_change(%{
          "user" => %{
            "current_password" => "invalid",
            "email" => "invalid",
            "email_confirmation" => "does not match"
          }
        })

      assert result =~ "Update email"
      assert result =~ "must have the @ sign and no spaces"
      assert result =~ "does not match"
    end

    @tag :update_email_live
    test "renders errors with invalid data (phx-submit)", %{
      conn: conn,
      user: user
    } do
      {:ok, lv, _html} = live(conn, ~p"/users/update_email")

      result =
        lv
        |> form("#update_email_form", %{
          "user" => %{
            "current_password" => "invalid",
            "email" => user.email,
            "email_confirmation" => user.email
          }
        })
        |> render_submit()

      assert result =~ "Update email"
      assert result =~ "did not change"
      assert result =~ "is not valid"
    end
  end
end
