defmodule PrepairWeb.PartLiveTest do
  use PrepairWeb.ConnCase

  import Phoenix.LiveViewTest
  import Prepair.ProductsFixtures

  @update_attrs %{
    average_lifetime_m: 43,
    country_of_origin: "some updated country_of_origin",
    description: "some updated description",
    end_of_production: "2023-07-12",
    image: "some updated image",
    main_material: "some updated main_material",
    name: "some updated name",
    reference: "some updated reference",
    start_of_production: "2023-07-12"
  }
  @invalid_attrs %{
    average_lifetime_m: nil,
    country_of_origin: nil,
    description: nil,
    end_of_production: nil,
    image: nil,
    main_material: nil,
    name: nil,
    reference: nil,
    start_of_production: nil
  }

  defp create_part(_) do
    part = part_fixture()
    %{part: part}
  end

  ##############################################################################
  ########################## AUTHORIZATION - VISITORS ##########################
  ##############################################################################
  describe "Authorization - visitors" do
    setup [:create_part]

    ######################## WHAT VISITORS CAN DO ? ############################

    # Nothing

    ####################### WHAT VISITORS CANNOT DO ? ##########################

    @tag :part_liveview
    test "visitors CANNOT list, edit or delete parts", %{conn: conn} do
      {:error, detail} = live(conn, ~p"/parts")

      assert detail ==
               {:redirect,
                %{
                  to: "/users/log_in",
                  flash: %{"error" => "You must log in to access this page."}
                }}
    end

    @tag :part_liveview
    test "visitors CANNOT see or edit a part",
         %{conn: conn, part: part} do
      {:error, detail} = live(conn, ~p"/parts/#{part.id}")

      assert detail ==
               {:redirect,
                %{
                  to: "/users/log_in",
                  flash: %{"error" => "You must log in to access this page."}
                }}
    end

    @tag :part_liveview
    test "visitors CANNOT create a part", %{conn: conn} do
      {:error, detail} = live(conn, ~p"/parts/new")

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
    setup [:create_part, :register_and_log_in_user]

    ########################### WHAT USERS CAN DO ? ############################

    @tag :part_liveview
    test "users CAN list parts", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/parts")

      assert html =~ "Listing Parts"
    end

    @tag :part_liveview
    test "users CAN see a part",
         %{conn: conn, part: part} do
      {:ok, _index_live, html} = live(conn, ~p"/parts")

      assert html =~ "#{part.name}"
    end

    @tag :part_liveview
    test "users CAN create a part", %{conn: conn} do
      valid_attrs = part_valid_attrs()
      {:ok, index_live, _html} = live(conn, ~p"/parts")

      assert index_live |> element("a", "New Part") |> render_click() =~
               "New Part"

      assert index_live
             |> form("#part-form", part: valid_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/parts")

      html = render(index_live)
      assert html =~ "Part created successfully"
      assert html =~ "some description"
    end

    ######################### WHAT USERS CANNOT DO ? ###########################

    @tag :part_liveview
    test "users CANNOT update a part",
         %{conn: conn, part: part} do
      conn = get(conn, ~p"/parts/#{part.id}/edit")

      assert conn.status == 403
      assert response(conn, 403) =~ "Forbidden"

      conn = get(conn, ~p"/parts/#{part.id}/show/edit")

      assert conn.status == 403
      assert response(conn, 403) =~ "Forbidden"
    end

    @tag :part_liveview
    test "there is no 'Edit' button in Parts Listing for users when they
    are not admin",
         %{conn: conn, part: part} do
      {:ok, index_live, _html} = live(conn, ~p"/parts")

      refute index_live
             |> element("#parts-#{part.id} a", "Edit")
             |> has_element?()
    end

    @tag :part_liveview
    test "there is no 'Edit' button in Part Show for users when they
    are not admin",
         %{conn: conn, part: part} do
      {:ok, index_live, _html} = live(conn, ~p"/parts/#{part.id}")

      refute index_live
             |> element("#parts-#{part.id} a", "Edit")
             |> has_element?()
    end

    @tag :part_liveview
    test "there is no 'Delete' button in Parts Listing for users when they
    are not admin",
         %{conn: conn, part: part} do
      {:ok, index_live, _html} = live(conn, ~p"/parts")

      refute index_live
             |> element("#parts-#{part.id} a", "Delete")
             |> has_element?()
    end

    # NOTE: There is no specific route to delete a part, only an
    # action. Maybe we can still enhance this test.
  end

  ##############################################################################
  ########################## FEATURES TESTS - ADMIN ############################
  ##############################################################################

  describe "Index" do
    setup [:create_part, :register_and_log_in_user, :make_user_admin]

    @tag :part_liveview
    test "lists all parts", %{conn: conn, part: part} do
      {:ok, _index_live, html} = live(conn, ~p"/parts")

      assert html =~ "Listing Parts"
      assert html =~ part.country_of_origin
    end

    @tag :part_liveview
    @tag :gettext
    test "index texts are translated to the first language in 'accept-language'
  which match one of the locales defined for the application",
         %{conn: conn, part: part} do
      conn = conn |> set_language_to_de_then_fr()
      {:ok, _index_live, html} = live(conn, ~p"/parts")

      assert html =~ "Référencement des pièces détachées"
      assert html =~ part.description
    end

    @tag :part_liveview
    @tag :gettext
    test "index texts are not translated ('en' is the default locale) if none
  of the languages in 'accept-language' is part of the locales defined for
  the app",
         %{conn: conn, part: part} do
      conn = conn |> set_language_to_unknown()
      {:ok, _index_live, html} = live(conn, ~p"/parts")

      assert html =~ "Listing Parts"
      assert html =~ part.description
    end

    @tag :part_liveview
    test "saves new part", %{conn: conn} do
      valid_attrs = part_valid_attrs()

      {:ok, index_live, _html} = live(conn, ~p"/parts")

      assert index_live |> element("a", "New Part") |> render_click() =~
               "New Part"

      assert_patch(index_live, ~p"/parts/new")

      assert index_live
             |> form("#part-form", part: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#part-form", part: valid_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/parts")

      html = render(index_live)
      assert html =~ "Part created successfully"
      assert html =~ "some country_of_origin"
    end

    @tag :part_liveview
    test "updates part in listing", %{conn: conn, part: part} do
      {:ok, index_live, _html} = live(conn, ~p"/parts")

      assert index_live
             |> element("#parts-#{part.id} a", "Edit")
             |> render_click() =~
               "Edit Part"

      assert_patch(index_live, ~p"/parts/#{part}/edit")

      assert index_live
             |> form("#part-form", part: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#part-form", part: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/parts")

      html = render(index_live)
      assert html =~ "Part updated successfully"
      assert html =~ "some updated country_of_origin"
    end

    @tag :part_liveview
    test "deletes part in listing", %{conn: conn, part: part} do
      {:ok, index_live, _html} = live(conn, ~p"/parts")

      assert index_live
             |> element("#parts-#{part.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#parts-#{part.id}")
    end
  end

  @tag :part_liveview
  describe "Show" do
    setup [:create_part, :register_and_log_in_user, :make_user_admin]

    test "displays part", %{conn: conn, part: part} do
      {:ok, _show_live, html} = live(conn, ~p"/parts/#{part}")

      assert html =~ "Show Part"
      assert html =~ part.country_of_origin
    end

    @tag :part_liveview
    @tag :gettext
    test "show texts are translated to the first language in 'accept-language'
  which match one of the locales defined for the application",
         %{conn: conn, part: part} do
      conn = conn |> set_language_to_de_then_fr()
      {:ok, _index_live, html} = live(conn, ~p"/parts/#{part}")

      assert html =~ "Afficher la pièce détachée"
      assert html =~ part.description
    end

    @tag :part_liveview
    @tag :gettext
    test "show texts are not translated ('en' is the default locale) if none
  of the languages in 'accept-language' is part of the locales defined for
  the app",
         %{conn: conn, part: part} do
      conn = conn |> set_language_to_unknown()
      {:ok, _index_live, html} = live(conn, ~p"/parts/#{part}")

      assert html =~ "Show Part"
      assert html =~ part.description
    end

    @tag :part_liveview
    test "updates part within modal", %{conn: conn, part: part} do
      {:ok, show_live, _html} = live(conn, ~p"/parts/#{part}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Part"

      assert_patch(show_live, ~p"/parts/#{part}/show/edit")

      assert show_live
             |> form("#part-form", part: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#part-form", part: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/parts/#{part}")

      html = render(show_live)
      assert html =~ "Part updated successfully"
      assert html =~ "some updated country_of_origin"
    end
  end
end
