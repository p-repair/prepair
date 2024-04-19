defmodule PrepairWeb.NotificationTemplateLiveTest do
  use PrepairWeb.ConnCase

  import Phoenix.LiveViewTest
  import Prepair.NotificationsFixtures

  @create_attrs %{
    name: "some name",
    description: "some description",
    title: "some title",
    content: "some content",
    condition: "some condition",
    need_action: false,
    draft: false
  }
  @update_attrs %{
    name: "some updated name",
    description: "some updated description",
    title: "some updated title",
    content: "some updated content",
    condition: "some updated condition",
    need_action: true,
    draft: true
  }
  @invalid_attrs %{
    name: nil,
    description: nil,
    title: nil,
    content: nil,
    condition: nil,
    need_action: false,
    draft: false
  }

  defp create_notification_template(_) do
    notification_template = notification_template_fixture()
    %{notification_template: notification_template}
  end

  ##############################################################################
  ########################## AUTHORIZATION - VISITORS ##########################
  ##############################################################################
  describe "Authorization - visitors" do
    setup [:create_notification_template]

    ######################## WHAT VISITORS CAN DO ? ############################

    # Nothing

    ####################### WHAT VISITORS CANNOT DO ? ##########################

    @tag :notification_template_liveview
    test "visitors CANNOT list, edit or delete notification templates",
         %{conn: conn} do
      {:error, detail} = live(conn, ~p"/notification_templates")

      assert detail ==
               {:redirect,
                %{
                  to: "/users/log_in",
                  flash: %{"error" => "You must log in to access this page."}
                }}
    end

    @tag :notification_template_liveview
    test "visitors CANNOT see or edit a notification template",
         %{conn: conn, notification_template: notification_template} do
      {:error, detail} =
        live(conn, ~p"/notification_templates/#{notification_template.uuid}")

      assert detail ==
               {:redirect,
                %{
                  to: "/users/log_in",
                  flash: %{"error" => "You must log in to access this page."}
                }}
    end

    @tag :notification_template_liveview
    test "visitors CANNOT create a notification template", %{conn: conn} do
      {:error, detail} = live(conn, ~p"/notification_templates/new")

      assert detail ==
               {:redirect,
                %{
                  to: "/users/log_in",
                  flash: %{"error" => "You must log in to access this page."}
                }}
    end
  end

  ##############################################################################
  ########################### AUTHORIZATION - USERS ############################
  ##############################################################################
  describe "Authorization - users" do
    setup [:create_notification_template, :register_and_log_in_user]

    ########################### WHAT USERS CAN DO ? ############################

    @tag :notification_template_liveview
    test "users CAN list notification templates", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/notification_templates")

      assert html =~ "Listing Notification templates"
    end

    @tag :notification_template_liveview
    test "users CAN see a notification template",
         %{conn: conn, notification_template: notification_template} do
      {:ok, _index_live, html} =
        live(conn, ~p"/notification_templates/#{notification_template.uuid}")

      assert html =~ "#{notification_template.name}"
    end

    @tag :notification_template_liveview
    test "users CAN create a notification template", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/notification_templates")

      assert index_live
             |> element("a", "New Notification template")
             |> render_click() =~
               "New Notification template"

      assert index_live
             |> form("#notification_template-form",
               notification_template: notification_template_valid_attrs()
             )
             |> render_submit()

      assert_patch(index_live, ~p"/notification_templates")

      html = render(index_live)
      assert html =~ "Notification template created successfully"
      assert html =~ "some description"
    end

    ######################### WHAT USERS CANNOT DO ? ###########################

    @tag :notification_template_liveview
    test "users CANNOT update a notification template",
         %{conn: conn, notification_template: notification_template} do
      conn =
        get(
          conn,
          ~p"/notification_templates/#{notification_template.uuid}/edit"
        )

      assert conn.status == 403
      assert response(conn, 403) =~ "Forbidden"

      conn =
        get(
          conn,
          ~p"/notification_templates/#{notification_template.uuid}/show/edit"
        )

      assert conn.status == 403
      assert response(conn, 403) =~ "Forbidden"
    end

    @tag :notification_template_liveview
    test "there is no 'Edit' button in Notification Templates Listing for users
    when they are not admin",
         %{conn: conn, notification_template: notification_template} do
      {:ok, index_live, _html} = live(conn, ~p"/notification_templates")

      refute index_live
             |> element(
               "#notification_templates-#{notification_template.uuid} a",
               "Edit"
             )
             |> has_element?()
    end

    @tag :notification_template_liveview
    test "there is no 'Edit' button in Notification Template Show for users when
    they are not admin",
         %{conn: conn, notification_template: notification_template} do
      {:ok, index_live, _html} =
        live(conn, ~p"/notification_templates/#{notification_template.uuid}")

      refute index_live
             |> element(
               "#notification_template-#{notification_template.uuid} a",
               "Edit"
             )
             |> has_element?()
    end

    @tag :notification_template_liveview
    test "there is no 'Delete' button in Notification Templates Listing for
    users when they are not admin",
         %{conn: conn, notification_template: notification_template} do
      {:ok, index_live, _html} = live(conn, ~p"/notification_templates")

      refute index_live
             |> element(
               "#notification_templates-#{notification_template.uuid} a",
               "Delete"
             )
             |> has_element?()
    end

    # NOTE: There is no specific route to delete a manufacturer, only an
    # action. Maybe we can still enhance this test.
  end

  ##############################################################################
  ########################## FEATURES TESTS - ADMIN ############################
  ##############################################################################

  describe "Index" do
    setup [
      :create_notification_template,
      :register_and_log_in_user,
      :make_user_admin
    ]

    @tag :notification_template_liveview
    test "lists all notification_templates", %{
      conn: conn,
      notification_template: notification_template
    } do
      {:ok, _index_live, html} = live(conn, ~p"/notification_templates")

      assert html =~ "Listing Notification templates"
      assert html =~ notification_template.name
    end

    @tag :notification_template_liveview
    @tag :gettext
    test "index texts are translated to the first language in 'accept-language'
  which match one of the locales defined for the application",
         %{conn: conn, notification_template: notification_template} do
      conn = conn |> set_language_to_de_then_fr()
      {:ok, _index_live, html} = live(conn, ~p"/notification_templates")

      assert html =~ "Référencement des modèles de notifications"
      assert html =~ notification_template.name
    end

    @tag :notification_template_liveview
    @tag :gettext
    test "index texts are not translated ('en' is the default locale) if none
  of the languages in 'accept-language' is part of the locales defined for
  the app",
         %{conn: conn, notification_template: notification_template} do
      conn = conn |> set_language_to_unknown()
      {:ok, _index_live, html} = live(conn, ~p"/notification_templates")

      assert html =~ "Listing Notification templates"
      assert html =~ notification_template.name
    end

    @tag :notification_template_liveview
    test "saves new notification_template", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/notification_templates")

      assert index_live
             |> element("a", "New Notification template")
             |> render_click() =~
               "New Notification template"

      assert_patch(index_live, ~p"/notification_templates/new")

      assert index_live
             |> form("#notification_template-form",
               notification_template: @invalid_attrs
             )
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#notification_template-form",
               notification_template: @create_attrs
             )
             |> render_submit()

      assert_patch(index_live, ~p"/notification_templates")

      html = render(index_live)
      assert html =~ "Notification template created successfully"
      assert html =~ "some name"
    end

    @tag :notification_template_liveview
    test "updates notification_template in listing", %{
      conn: conn,
      notification_template: notification_template
    } do
      {:ok, index_live, _html} = live(conn, ~p"/notification_templates")

      assert index_live
             |> element(
               "#notification_templates-#{notification_template.uuid} a",
               "Edit"
             )
             |> render_click() =~
               "Edit Notification template"

      assert_patch(
        index_live,
        ~p"/notification_templates/#{notification_template}/edit"
      )

      assert index_live
             |> form("#notification_template-form",
               notification_template: @invalid_attrs
             )
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#notification_template-form",
               notification_template: @update_attrs
             )
             |> render_submit()

      assert_patch(index_live, ~p"/notification_templates")

      html = render(index_live)
      assert html =~ "Notification template updated successfully"
      assert html =~ "some updated name"
    end

    @tag :notification_template_liveview
    test "deletes notification_template in listing", %{
      conn: conn,
      notification_template: notification_template
    } do
      {:ok, index_live, _html} = live(conn, ~p"/notification_templates")

      assert index_live
             |> element(
               "#notification_templates-#{notification_template.uuid} a",
               "Delete"
             )
             |> render_click()

      refute has_element?(
               index_live,
               "#notification_templates-#{notification_template.uuid}"
             )
    end
  end

  @tag :notification_template_liveview
  describe "Show" do
    setup [
      :create_notification_template,
      :register_and_log_in_user,
      :make_user_admin
    ]

    test "displays notification_template", %{
      conn: conn,
      notification_template: notification_template
    } do
      {:ok, _show_live, html} =
        live(conn, ~p"/notification_templates/#{notification_template}")

      assert html =~ "Show Notification template"
      assert html =~ notification_template.name
    end

    @tag :notification_template_liveview
    @tag :gettext
    test "show texts are translated to the first language in 'accept-language'
  which match one of the locales defined for the application",
         %{conn: conn, notification_template: notification_template} do
      conn = conn |> set_language_to_de_then_fr()

      {:ok, _index_live, html} =
        live(conn, ~p"/notification_templates/#{notification_template}")

      assert html =~ "Afficher le modèle de notification"
      assert html =~ notification_template.name
    end

    @tag :notification_template_liveview
    @tag :gettext
    test "show texts are not translated ('en' is the default locale) if none
  of the languages in 'accept-language' is part of the locales defined for
  the app",
         %{conn: conn, notification_template: notification_template} do
      conn = conn |> set_language_to_unknown()

      {:ok, _index_live, html} =
        live(conn, ~p"/notification_templates/#{notification_template}")

      assert html =~ "Show Notification template"
      assert html =~ notification_template.name
    end

    @tag :notification_template_liveview
    test "updates notification_template within modal", %{
      conn: conn,
      notification_template: notification_template
    } do
      {:ok, show_live, _html} =
        live(conn, ~p"/notification_templates/#{notification_template}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Notification template"

      assert_patch(
        show_live,
        ~p"/notification_templates/#{notification_template}/show/edit"
      )

      assert show_live
             |> form("#notification_template-form",
               notification_template: @invalid_attrs
             )
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#notification_template-form",
               notification_template: @update_attrs
             )
             |> render_submit()

      assert_patch(
        show_live,
        ~p"/notification_templates/#{notification_template}"
      )

      html = render(show_live)
      assert html =~ "Notification template updated successfully"
      assert html =~ "some updated name"
    end
  end
end
