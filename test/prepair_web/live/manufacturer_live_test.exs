defmodule PrepairWeb.ManufacturerLiveTest do
  use PrepairWeb.ConnCase

  import Phoenix.LiveViewTest
  import Prepair.ProductsFixtures

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

  describe "Index" do
    setup [:create_manufacturer, :register_and_log_in_user]

    test "lists all manufacturers", %{conn: conn, manufacturer: manufacturer} do
      {:ok, _index_live, html} = live(conn, ~p"/manufacturers")

      assert html =~ "Listing Manufacturers"
      assert html =~ manufacturer.description
    end

    @tag :gettext
    test "index texts are translated to the first language in 'accept-language'
  which match one of the locales defined for the application",
         %{conn: conn, manufacturer: manufacturer} do
      conn = conn |> set_language_to_de_then_fr()
      {:ok, _index_live, html} = live(conn, ~p"/manufacturers")

      assert html =~ "Référencement des fabricants"
      assert html =~ manufacturer.description
    end

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

    test "updates manufacturer in listing", %{
      conn: conn,
      manufacturer: manufacturer
    } do
      {:ok, index_live, _html} = live(conn, ~p"/manufacturers")

      assert index_live
             |> element("#manufacturers-#{manufacturer.uuid} a", "Edit")
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

    test "deletes manufacturer in listing", %{
      conn: conn,
      manufacturer: manufacturer
    } do
      {:ok, index_live, _html} = live(conn, ~p"/manufacturers")

      assert index_live
             |> element("#manufacturers-#{manufacturer.uuid} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#manufacturers-#{manufacturer.uuid}")
    end
  end

  describe "Show" do
    setup [:create_manufacturer, :register_and_log_in_user]

    test "displays manufacturer", %{conn: conn, manufacturer: manufacturer} do
      {:ok, _show_live, html} = live(conn, ~p"/manufacturers/#{manufacturer}")

      assert html =~ "Show Manufacturer"
      assert html =~ manufacturer.description
    end

    @tag :gettext
    test "show texts are translated to the first language in 'accept-language'
  which match one of the locales defined for the application",
         %{conn: conn, manufacturer: manufacturer} do
      conn = conn |> set_language_to_de_then_fr()
      {:ok, _index_live, html} = live(conn, ~p"/manufacturers/#{manufacturer}")

      assert html =~ "Afficher le fabricant"
      assert html =~ manufacturer.description
    end

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
