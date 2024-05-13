defmodule PrepairWeb.ManufacturerLiveTest do
  use PrepairWeb.ConnCase

  import Phoenix.LiveViewTest
  import Prepair.LegacyContexts.ProductsFixtures

  @update_attrs %{
    description: "some updated description",
    image: "some updated image",
    name: "some updated name"
  }
  @invalid_attrs %{description: nil, image: nil, name: nil}

  defp create_manufacturer(_) do
    manufacturer = manufacturer_fixture()
    %{manufacturer: manufacturer}
  end

  ##############################################################################
  ########################## AUTHORIZATION - VISITORS ##########################
  ##############################################################################
  describe "Authorization - visitors" do
    setup [:create_manufacturer]

    ######################## WHAT VISITORS CAN DO ? ############################

    # Nothing

    ####################### WHAT VISITORS CANNOT DO ? ##########################

    @tag :manufacturer_liveview
    test "visitors CANNOT list, edit or delete manufacturers", %{conn: conn} do
      {:error, detail} = live(conn, ~p"/manufacturers")

      assert detail ==
               {:redirect,
                %{
                  to: "/users/log_in",
                  flash: %{"error" => "You must log in to access this page."}
                }}
    end

    @tag :manufacturer_liveview
    test "visitors CANNOT see or edit a manufacturer",
         %{conn: conn, manufacturer: manufacturer} do
      {:error, detail} = live(conn, ~p"/manufacturers/#{manufacturer.id}")

      assert detail ==
               {:redirect,
                %{
                  to: "/users/log_in",
                  flash: %{"error" => "You must log in to access this page."}
                }}
    end

    @tag :manufacturer_liveview
    test "visitors CANNOT create a manufacturer", %{conn: conn} do
      {:error, detail} = live(conn, ~p"/manufacturers/new")

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
    setup [:create_manufacturer, :register_and_log_in_user]

    ########################### WHAT USERS CAN DO ? ############################

    @tag :manufacturer_liveview
    test "users CAN list manufacturers", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/manufacturers")

      assert html =~ "Listing Manufacturers"
    end

    @tag :manufacturer_liveview
    test "users CAN see a manufacturer",
         %{conn: conn, manufacturer: manufacturer} do
      {:ok, _index_live, html} = live(conn, ~p"/manufacturers")

      assert html =~ "#{manufacturer.name}"
    end

    @tag :manufacturer_liveview
    test "users CAN create a manufacturer", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/manufacturers")

      assert index_live |> element("a", "New Manufacturer") |> render_click() =~
               "New Manufacturer"

      assert index_live
             |> form("#manufacturer-form",
               manufacturer: manufacturer_valid_attrs()
             )
             |> render_submit()

      assert_patch(index_live, ~p"/manufacturers")

      html = render(index_live)
      assert html =~ "Manufacturer created successfully"
      assert html =~ "some description"
    end

    ######################### WHAT USERS CANNOT DO ? ###########################

    @tag :manufacturer_liveview
    test "users CANNOT update a manufacturer",
         %{conn: conn, manufacturer: manufacturer} do
      conn = get(conn, ~p"/manufacturers/#{manufacturer.id}/edit")

      assert conn.status == 403
      assert response(conn, 403) =~ "Forbidden"

      conn = get(conn, ~p"/manufacturers/#{manufacturer.id}/show/edit")

      assert conn.status == 403
      assert response(conn, 403) =~ "Forbidden"
    end

    @tag :manufacturer_liveview
    test "there is no 'Edit' button in Manufacturers Listing for users when they
    are not admin",
         %{conn: conn, manufacturer: manufacturer} do
      {:ok, index_live, _html} = live(conn, ~p"/manufacturers")

      refute index_live
             |> element("#manufacturers-#{manufacturer.id} a", "Edit")
             |> has_element?()
    end

    @tag :manufacturer_liveview
    test "there is no 'Edit' button in Manufacturer Show for users when they
    are not admin",
         %{conn: conn, manufacturer: manufacturer} do
      {:ok, index_live, _html} =
        live(conn, ~p"/manufacturers/#{manufacturer.id}")

      refute index_live
             |> element("#manufacturers-#{manufacturer.id} a", "Edit")
             |> has_element?()
    end

    @tag :manufacturer_liveview
    test "there is no 'Delete' button in Manufacturers Listing for users when
    they are not admin",
         %{conn: conn, manufacturer: manufacturer} do
      {:ok, index_live, _html} = live(conn, ~p"/manufacturers")

      refute index_live
             |> element("#manufacturers-#{manufacturer.id} a", "Delete")
             |> has_element?()
    end

    # NOTE: There is no specific route to delete a manufacturer, only an
    # action. Maybe we can still enhance this test.
  end

  ##############################################################################
  ########################## FEATURES TESTS - ADMIN ############################
  ##############################################################################

  describe "Index" do
    setup [:create_manufacturer, :register_and_log_in_user, :make_user_admin]

    test "lists all manufacturers", %{conn: conn, manufacturer: manufacturer} do
      {:ok, _index_live, html} = live(conn, ~p"/manufacturers")

      assert html =~ "Listing Manufacturers"
      assert html =~ manufacturer.description
    end

    @tag :manufacturer_liveview
    @tag :gettext
    test "index texts are translated to the first language in 'accept-language'
  which match one of the locales defined for the application",
         %{conn: conn, manufacturer: manufacturer} do
      conn = conn |> set_language_to_de_then_fr()
      {:ok, _index_live, html} = live(conn, ~p"/manufacturers")

      assert html =~ "Référencement des fabricants"
      assert html =~ manufacturer.description
    end

    @tag :manufacturer_liveview
    @tag :gettext
    test "index texts are not translated ('en' is the default locale) if none
  of the languages in 'accept-language' is part of the locales defined for
  the app",
         %{conn: conn, manufacturer: manufacturer} do
      conn = conn |> set_language_to_unknown()
      {:ok, _index_live, html} = live(conn, ~p"/manufacturers")

      assert html =~ "Listing Manufacturers"
      assert html =~ manufacturer.description
    end

    @tag :manufacturer_liveview
    test "saves new manufacturer", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/manufacturers")

      assert index_live |> element("a", "New Manufacturer") |> render_click() =~
               "New Manufacturer"

      assert_patch(index_live, ~p"/manufacturers/new")

      assert index_live
             |> form("#manufacturer-form", manufacturer: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#manufacturer-form",
               manufacturer: manufacturer_valid_attrs()
             )
             |> render_submit()

      assert_patch(index_live, ~p"/manufacturers")

      html = render(index_live)
      assert html =~ "Manufacturer created successfully"
      assert html =~ "some description"
    end

    @tag :manufacturer_liveview
    test "updates manufacturer in listing", %{
      conn: conn,
      manufacturer: manufacturer
    } do
      {:ok, index_live, _html} = live(conn, ~p"/manufacturers")

      assert index_live
             |> element("#manufacturers-#{manufacturer.id} a", "Edit")
             |> render_click() =~
               "Edit Manufacturer"

      assert_patch(index_live, ~p"/manufacturers/#{manufacturer}/edit")

      assert index_live
             |> form("#manufacturer-form", manufacturer: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#manufacturer-form", manufacturer: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/manufacturers")

      html = render(index_live)
      assert html =~ "Manufacturer updated successfully"
      assert html =~ "some updated description"
    end

    @tag :manufacturer_liveview
    test "deletes manufacturer in listing", %{
      conn: conn,
      manufacturer: manufacturer
    } do
      {:ok, index_live, _html} = live(conn, ~p"/manufacturers")

      assert index_live
             |> element("#manufacturers-#{manufacturer.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#manufacturers-#{manufacturer.id}")
    end
  end

  @tag :manufacturer_liveview
  describe "Show" do
    setup [:create_manufacturer, :register_and_log_in_user, :make_user_admin]

    test "displays manufacturer", %{conn: conn, manufacturer: manufacturer} do
      {:ok, _show_live, html} = live(conn, ~p"/manufacturers/#{manufacturer}")

      assert html =~ "Show Manufacturer"
      assert html =~ manufacturer.description
    end

    @tag :manufacturer_liveview
    @tag :gettext
    test "show texts are translated to the first language in 'accept-language'
  which match one of the locales defined for the application",
         %{conn: conn, manufacturer: manufacturer} do
      conn = conn |> set_language_to_de_then_fr()
      {:ok, _index_live, html} = live(conn, ~p"/manufacturers/#{manufacturer}")

      assert html =~ "Afficher le fabricant"
      assert html =~ manufacturer.description
    end

    @tag :manufacturer_liveview
    @tag :gettext
    test "show texts are not translated ('en' is the default locale) if none
  of the languages in 'accept-language' is part of the locales defined for
  the app",
         %{conn: conn, manufacturer: manufacturer} do
      conn = conn |> set_language_to_unknown()
      {:ok, _index_live, html} = live(conn, ~p"/manufacturers/#{manufacturer}")

      assert html =~ "Show Manufacturer"
      assert html =~ manufacturer.description
    end

    @tag :manufacturer_liveview
    test "updates manufacturer within modal", %{
      conn: conn,
      manufacturer: manufacturer
    } do
      {:ok, show_live, _html} = live(conn, ~p"/manufacturers/#{manufacturer}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Manufacturer"

      assert_patch(show_live, ~p"/manufacturers/#{manufacturer}/show/edit")

      assert show_live
             |> form("#manufacturer-form", manufacturer: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#manufacturer-form", manufacturer: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/manufacturers/#{manufacturer}")

      html = render(show_live)
      assert html =~ "Manufacturer updated successfully"
      assert html =~ "some updated description"
    end
  end
end
