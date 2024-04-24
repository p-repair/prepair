defmodule PrepairWeb.ProductLiveTest do
  use PrepairWeb.ConnCase

  import Phoenix.LiveViewTest
  import Prepair.ProductsFixtures

  @update_attrs %{
    average_lifetime_m: 43,
    country_of_origin: "some updated country_of_origin",
    description: "some updated description",
    end_of_production: "2023-07-12",
    image: "some updated image",
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
    name: nil,
    reference: nil,
    start_of_production: nil
  }

  defp create_product(_) do
    product = product_fixture()
    %{product: product}
  end

  ##############################################################################
  ########################## AUTHORIZATION - VISITORS ##########################
  ##############################################################################
  describe "Authorization - visitors" do
    setup [:create_product]

    ######################## WHAT VISITORS CAN DO ? ############################

    # Nothing

    ####################### WHAT VISITORS CANNOT DO ? ##########################

    @tag :product_liveview
    test "visitors CANNOT list, edit or delete products", %{conn: conn} do
      {:error, detail} = live(conn, ~p"/products")

      assert detail ==
               {:redirect,
                %{
                  to: "/users/log_in",
                  flash: %{"error" => "You must log in to access this page."}
                }}
    end

    @tag :product_liveview
    test "visitors CANNOT see or edit a product",
         %{conn: conn, product: product} do
      {:error, detail} = live(conn, ~p"/products/#{product.id}")

      assert detail ==
               {:redirect,
                %{
                  to: "/users/log_in",
                  flash: %{"error" => "You must log in to access this page."}
                }}
    end

    @tag :product_liveview
    test "visitors CANNOT create a product", %{conn: conn} do
      {:error, detail} = live(conn, ~p"/products/new")

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
    setup [:create_product, :register_and_log_in_user]

    ########################### WHAT USERS CAN DO ? ############################

    @tag :product_liveview
    test "users CAN list product", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/products")

      assert html =~ "Listing Products"
    end

    @tag :product_liveview
    test "users CAN see a product",
         %{conn: conn, product: product} do
      {:ok, _index_live, html} = live(conn, ~p"/products")

      assert html =~ "#{product.name}"
    end

    @tag :product_liveview
    test "users CAN create a product", %{conn: conn} do
      valid_attrs = product_valid_attrs()
      {:ok, index_live, _html} = live(conn, ~p"/products")

      assert index_live |> element("a", "New Product") |> render_click() =~
               "New Product"

      assert index_live
             |> form("#product-form", product: valid_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/products")

      html = render(index_live)
      assert html =~ "Product created successfully"
      assert html =~ "some description"
    end

    ######################### WHAT USERS CANNOT DO ? ###########################

    @tag :product_liveview
    test "users CANNOT update a product",
         %{conn: conn, product: product} do
      conn = get(conn, ~p"/products/#{product.id}/edit")

      assert conn.status == 403
      assert response(conn, 403) =~ "Forbidden"

      conn = get(conn, ~p"/products/#{product.id}/show/edit")

      assert conn.status == 403
      assert response(conn, 403) =~ "Forbidden"
    end

    @tag :product_liveview
    test "there is no 'Edit' button in Products Listing for users when they
    are not admin",
         %{conn: conn, product: product} do
      {:ok, index_live, _html} = live(conn, ~p"/products")

      refute index_live
             |> element("#products-#{product.id} a", "Edit")
             |> has_element?()
    end

    @tag :product_liveview
    test "there is no 'Edit' button in Product Show for users when they
    are not admin",
         %{conn: conn, product: product} do
      {:ok, index_live, _html} = live(conn, ~p"/products/#{product.id}")

      refute index_live
             |> element("#products-#{product.id} a", "Edit")
             |> has_element?()
    end

    @tag :product_liveview
    test "there is no 'Delete' button in Products Listing for users when they
    are not admin",
         %{conn: conn, product: product} do
      {:ok, index_live, _html} = live(conn, ~p"/products")

      refute index_live
             |> element("#products-#{product.id} a", "Delete")
             |> has_element?()
    end

    # NOTE: There is no specific route to delete a product, only an
    # action. Maybe we can still enhance this test.
  end

  ##############################################################################
  ########################## FEATURES TESTS - ADMIN ############################
  ##############################################################################

  describe "Index" do
    setup [:create_product, :register_and_log_in_user, :make_user_admin]

    @tag :product_liveview
    test "lists all products", %{conn: conn, product: product} do
      {:ok, _index_live, html} = live(conn, ~p"/products")

      assert html =~ "Listing Products"
      assert html =~ product.country_of_origin
    end

    @tag :product_liveview
    @tag :gettext
    test "index texts are translated to the first language in 'accept-language'
  which match one of the locales defined for the application",
         %{conn: conn, product: product} do
      conn = conn |> set_language_to_de_then_fr()
      {:ok, _index_live, html} = live(conn, ~p"/products")

      assert html =~ "Référencement des produits"
      assert html =~ product.description
    end

    @tag :product_liveview
    @tag :gettext
    test "index texts are not translated ('en' is the default locale) if none
  of the languages in 'accept-language' is part of the locales defined for
  the app",
         %{conn: conn, product: product} do
      conn = conn |> set_language_to_unknown()
      {:ok, _index_live, html} = live(conn, ~p"/products")

      assert html =~ "Listing Products"
      assert html =~ product.description
    end

    @tag :product_liveview
    test "saves new product", %{conn: conn} do
      valid_attrs = product_valid_attrs()

      {:ok, index_live, _html} = live(conn, ~p"/products")

      assert index_live |> element("a", "New Product") |> render_click() =~
               "New Product"

      assert_patch(index_live, ~p"/products/new")

      assert index_live
             |> form("#product-form", product: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#product-form", product: valid_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/products")

      html = render(index_live)
      assert html =~ "Product created successfully"
      assert html =~ "some country_of_origin"
    end

    @tag :product_liveview
    test "updates product in listing", %{conn: conn, product: product} do
      {:ok, index_live, _html} = live(conn, ~p"/products")

      assert index_live
             |> element("#products-#{product.id} a", "Edit")
             |> render_click() =~
               "Edit Product"

      assert_patch(index_live, ~p"/products/#{product}/edit")

      assert index_live
             |> form("#product-form", product: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#product-form", product: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/products")

      html = render(index_live)
      assert html =~ "Product updated successfully"
      assert html =~ "some updated country_of_origin"
    end

    @tag :product_liveview
    test "deletes product in listing", %{conn: conn, product: product} do
      {:ok, index_live, _html} = live(conn, ~p"/products")

      assert index_live
             |> element("#products-#{product.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#products-#{product.id}")
    end
  end

  @tag :product_liveview
  describe "Show" do
    setup [:create_product, :register_and_log_in_user, :make_user_admin]

    test "displays product", %{conn: conn, product: product} do
      {:ok, _show_live, html} = live(conn, ~p"/products/#{product}")

      assert html =~ "Show Product"
      assert html =~ product.country_of_origin
    end

    @tag :product_liveview
    @tag :gettext
    test "show texts are translated to the first language in 'accept-language'
  which match one of the locales defined for the application",
         %{conn: conn, product: product} do
      conn = conn |> set_language_to_de_then_fr()
      {:ok, _index_live, html} = live(conn, ~p"/products/#{product}")

      assert html =~ "Afficher le produit"
      assert html =~ product.description
    end

    @tag :product_liveview
    @tag :gettext
    test "show texts are not translated ('en' is the default locale) if none
  of the languages in 'accept-language' is part of the locales defined for
  the app",
         %{conn: conn, product: product} do
      conn = conn |> set_language_to_unknown()
      {:ok, _index_live, html} = live(conn, ~p"/products/#{product}")

      assert html =~ "Show Product"
      assert html =~ product.description
    end

    @tag :product_liveview
    test "updates product within modal", %{conn: conn, product: product} do
      {:ok, show_live, _html} = live(conn, ~p"/products/#{product}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Product"

      assert_patch(show_live, ~p"/products/#{product}/show/edit")

      assert show_live
             |> form("#product-form", product: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#product-form", product: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/products/#{product}")

      html = render(show_live)
      assert html =~ "Product updated successfully"
      assert html =~ "some updated country_of_origin"
    end
  end
end
