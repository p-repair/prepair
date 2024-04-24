defmodule PrepairWeb.CategoryLiveTest do
  use PrepairWeb.ConnCase

  import Phoenix.LiveViewTest
  import Prepair.ProductsFixtures

  @update_attrs %{
    average_lifetime_m: 43,
    description: "some updated description",
    image: "some updated image",
    name: "some updated name"
  }
  @invalid_attrs %{
    average_lifetime_m: nil,
    description: nil,
    image: nil,
    name: nil
  }

  defp create_category(_) do
    category = category_fixture()
    %{category: category}
  end

  ##############################################################################
  ########################## AUTHORIZATION - VISITORS ##########################
  ##############################################################################
  describe "Authorization - visitors" do
    setup [:create_category]

    ######################## WHAT VISITORS CAN DO ? ############################

    # Nothing

    ####################### WHAT VISITORS CANNOT DO ? ##########################

    @tag :category_liveview
    test "visitors CANNOT list, edit or delete categories", %{conn: conn} do
      {:error, detail} = live(conn, ~p"/categories")

      assert detail ==
               {:redirect,
                %{
                  to: "/users/log_in",
                  flash: %{"error" => "You must log in to access this page."}
                }}
    end

    @tag :category_liveview
    test "visitors CANNOT see or edit a category",
         %{conn: conn, category: category} do
      {:error, detail} = live(conn, ~p"/categories/#{category.id}")

      assert detail ==
               {:redirect,
                %{
                  to: "/users/log_in",
                  flash: %{"error" => "You must log in to access this page."}
                }}
    end

    @tag :category_liveview
    test "visitors CANNOT create a category", %{conn: conn} do
      {:error, detail} = live(conn, ~p"/categories/new")

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
    setup [:create_category, :register_and_log_in_user]

    ########################### WHAT USERS CAN DO ? ############################

    @tag :category_liveview
    test "users CAN list categories", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/categories")

      assert html =~ "Listing Categories"
    end

    @tag :category_liveview
    test "users CAN see a category",
         %{conn: conn, category: category} do
      {:ok, _index_live, html} = live(conn, ~p"/categories")

      assert html =~ "#{category.name}"
    end

    @tag :category_liveview
    test "users CAN create a category", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/categories")

      assert index_live |> element("a", "New Category") |> render_click() =~
               "New Category"

      assert index_live
             |> form("#category-form", category: category_valid_attrs())
             |> render_submit()

      assert_patch(index_live, ~p"/categories")

      html = render(index_live)
      assert html =~ "Category created successfully"
      assert html =~ "some description"
    end

    ######################### WHAT USERS CANNOT DO ? ###########################

    @tag :category_liveview
    test "users CANNOT update a category",
         %{conn: conn, category: category} do
      conn = get(conn, ~p"/categories/#{category.id}/edit")

      assert conn.status == 403
      assert response(conn, 403) =~ "Forbidden"

      conn = get(conn, ~p"/categories/#{category.id}/show/edit")

      assert conn.status == 403
      assert response(conn, 403) =~ "Forbidden"
    end

    @tag :category_liveview
    test "there is no 'Edit' button in Categories Listing for users when they
    are not admin",
         %{conn: conn, category: category} do
      {:ok, index_live, _html} = live(conn, ~p"/categories")

      refute index_live
             |> element("#categories-#{category.id} a", "Edit")
             |> has_element?()
    end

    @tag :category_liveview
    test "there is no 'Edit' button in Category Show for users when they
    are not admin",
         %{conn: conn, category: category} do
      {:ok, index_live, _html} = live(conn, ~p"/categories/#{category.id}")

      refute index_live
             |> element("#category-#{category.id} a", "Edit")
             |> has_element?()
    end

    @tag :category_liveview
    test "there is no 'Delete' button in Categories Listing for users when they
    are not admin",
         %{conn: conn, category: category} do
      {:ok, index_live, _html} = live(conn, ~p"/categories")

      refute index_live
             |> element("#categories-#{category.id} a", "Delete")
             |> has_element?()
    end

    # NOTE: There is no specific route to delete a manufacturer, only an
    # action. Maybe we can still enhance this test.
  end

  ##############################################################################
  ########################## FEATURES TESTS - ADMIN ############################
  ##############################################################################
  describe "Index" do
    setup [:create_category, :register_and_log_in_user, :make_user_admin]

    @tag :category_liveview
    test "lists all categories", %{conn: conn, category: category} do
      {:ok, _index_live, html} = live(conn, ~p"/categories")

      assert html =~ "Listing Categories"
      assert html =~ category.description
    end

    @tag :category_liveview
    @tag :gettext
    test "index texts are translated to the first language in 'accept-language'
  which match one of the locales defined for the application",
         %{conn: conn, category: category} do
      conn = conn |> set_language_to_de_then_fr()
      {:ok, _index_live, html} = live(conn, ~p"/categories")

      assert html =~ "Référencement des catégories"
      assert html =~ category.description
    end

    @tag :category_liveview
    @tag :gettext
    test "index texts are not translated ('en' is the default locale) if none
  of the languages in 'accept-language' is part of the locales defined for
  the app",
         %{conn: conn, category: category} do
      conn = conn |> set_language_to_unknown()
      {:ok, _index_live, html} = live(conn, ~p"/categories")

      assert html =~ "Listing Categories"
      assert html =~ category.description
    end

    @tag :category_liveview
    test "saves new category", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/categories")

      assert index_live |> element("a", "New Category") |> render_click() =~
               "New Category"

      assert_patch(index_live, ~p"/categories/new")

      assert index_live
             |> form("#category-form", category: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#category-form", category: category_valid_attrs())
             |> render_submit()

      assert_patch(index_live, ~p"/categories")

      html = render(index_live)
      assert html =~ "Category created successfully"
      assert html =~ "some description"
    end

    @tag :category_liveview
    test "updates category in listing", %{conn: conn, category: category} do
      {:ok, index_live, _html} = live(conn, ~p"/categories")

      assert index_live
             |> element("#categories-#{category.id} a", "Edit")
             |> render_click() =~
               "Edit Category"

      assert_patch(index_live, ~p"/categories/#{category}/edit")

      assert index_live
             |> form("#category-form", category: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#category-form", category: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/categories")

      html = render(index_live)
      assert html =~ "Category updated successfully"
      assert html =~ "some updated description"
    end

    @tag :category_liveview
    test "deletes category in listing", %{conn: conn, category: category} do
      {:ok, index_live, _html} = live(conn, ~p"/categories")

      assert index_live
             |> element("#categories-#{category.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#categories-#{category.id}")
    end
  end

  @tag :category_liveview
  describe "Show" do
    setup [:create_category, :register_and_log_in_user, :make_user_admin]

    test "displays category", %{conn: conn, category: category} do
      {:ok, _show_live, html} = live(conn, ~p"/categories/#{category}")

      assert html =~ "Show Category"
      assert html =~ category.description
    end

    @tag :category_liveview
    @tag :gettext
    test "show texts are translated to the first language in 'accept-language'
  which match one of the locales defined for the application",
         %{conn: conn, category: category} do
      conn = conn |> set_language_to_de_then_fr()
      {:ok, _index_live, html} = live(conn, ~p"/categories/#{category}")

      assert html =~ "Afficher la catégorie"
      assert html =~ category.description
    end

    @tag :category_liveview
    @tag :gettext
    test "show texts are not translated ('en' is the default locale) if none
  of the languages in 'accept-language' is part of the locales defined for
  the app",
         %{conn: conn, category: category} do
      conn = conn |> set_language_to_unknown()
      {:ok, _index_live, html} = live(conn, ~p"/categories/#{category}")

      assert html =~ "Show Category"
      assert html =~ category.description
    end

    @tag :category_liveview
    test "updates category within modal", %{conn: conn, category: category} do
      {:ok, show_live, _html} = live(conn, ~p"/categories/#{category}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Category"

      assert_patch(show_live, ~p"/categories/#{category}/show/edit")

      assert show_live
             |> form("#category-form", category: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#category-form", category: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/categories/#{category}")

      html = render(show_live)
      assert html =~ "Category updated successfully"
      assert html =~ "some updated description"
    end
  end
end
