defmodule PrepairWeb.Api.Products.ProductControllerTest do
  use PrepairWeb.ConnCase

  import Prepair.LegacyContexts.NotificationsFixtures
  import Prepair.LegacyContexts.ProductsFixtures
  import PrepairWeb.AuthorizationTestsMacro
  alias PrepairWeb.Api.Products.ProductJSON
  alias Prepair.AshDomains.Products.Product

  # NOTE: params needed for authorization tests macros
  @group_name "products"
  @context_name "products"
  @short_module "product"
  @object_name :product

  @update_attrs %{
    name: "some updated name",
    reference: "some updated reference",
    description: "some updated description",
    image: "some updated image",
    average_lifetime_m: 43,
    country_of_origin: "some updated country_of_origin",
    start_of_production: ~D[2023-09-07],
    end_of_production: ~D[2037-09-07]
  }

  @invalid_attrs %{
    name: nil,
    reference: nil,
    description: nil,
    image: nil,
    average_lifetime_m: nil,
    country_of_origin: nil,
    start_of_production: nil,
    end_of_production: nil
  }

  defp create_product(_) do
    parts = create_parts()
    part_ids = create_part_ids(parts)
    notification_templates = create_notification_templates()

    notification_template_ids =
      create_notification_template_ids(notification_templates)

    product =
      product_fixture(%{
        part_ids: part_ids,
        notification_template_ids: notification_template_ids
      })

    %{product: product}
  end

  defp to_normalised_json(data) do
    data
    |> ProductJSON.data()
    |> normalise_json()
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  setup [:create_and_set_api_key]

  ##############################################################################
  ########################## VISITORS - AUTHORIZATION ##########################
  ##############################################################################
  describe "visitors authorization:" do
    ######################## WHAT VISITORS CAN DO ? ############################

    # Nothing

    ####################### WHAT VISITORS CANNOT DO ? ##########################

    setup [:create_product]

    @tag :product_controller
    test_visitors_cannot_list_objects()

    @tag :product_controller
    test_visitors_cannot_see_an_object()

    @tag :product_controller
    test_visitors_cannot_create_an_object()

    @tag :product_controller
    test_visitors_cannot_update_an_object()

    @tag :product_controller
    test_visitors_cannot_delete_an_object()
  end

  ##############################################################################
  ########################### USERS - AUTHORIZATION ############################
  ##############################################################################
  describe "users authorization:" do
    setup [:register_and_log_in_user, :create_product]

    ########################### WHAT USERS CAN DO ? ############################

    @tag :product_controller
    test_users_can_list_objects()

    @tag :product_controller
    test_users_can_see_an_object()

    @tag :product_controller
    test_users_can_create_an_object()

    ######################### WHAT USERS CANNOT DO ? ###########################

    @tag :product_controller
    test_users_cannot_update_an_object()

    @tag :product_controller
    test_users_cannot_delete_an_object()
  end

  ##############################################################################
  ########################## FEATURES TESTS - ADMIN ############################
  ##############################################################################

  describe "index" do
    setup [:register_and_log_in_user, :create_product, :make_user_admin]

    @tag :product_controller
    test "lists all products when no query parameters are passed", %{
      conn: conn,
      product: product
    } do
      conn = get(conn, ~p"/api/v1/products/products")

      assert json_response(conn, 200)["data"] == [
               product |> to_normalised_json()
             ]
    end

    @tag :product_controller
    test "filter by product_ids when :product_ids is set in query parameters",
         %{conn: conn, product: product} do
      _product_2 = product_fixture()

      product_id = product.id
      params = %{"product_ids" => "#{product_id}"}

      conn = get(conn, ~p"/api/v1/products/products", params)

      assert json_response(conn, 200)["data"] == [
               product |> to_normalised_json()
             ]
    end

    @tag :product_controller
    test "filter by category_id when :category_id is set in query parameters",
         %{conn: conn, product: _product} do
      category_id = category_fixture().id
      product_2 = product_fixture(%{category_id: category_id})

      params = %{"category_id" => "#{category_id}"}

      conn = get(conn, ~p"/api/v1/products/products", params)

      assert json_response(conn, 200)["data"] == [
               product_2 |> to_normalised_json()
             ]
    end

    @tag :product_controller
    test "filter by manufacturer_id when :manufacturer_id is set in query
    parameters",
         %{conn: conn, product: _product} do
      manufacturer_id = manufacturer_fixture().id
      product_2 = product_fixture(%{manufacturer_id: manufacturer_id})

      params = %{"manufacturer_id" => "#{manufacturer_id}"}

      conn = get(conn, ~p"/api/v1/products/products", params)

      assert json_response(conn, 200)["data"] == [
               product_2 |> to_normalised_json()
             ]
    end

    @tag :product_controller
    test "filter by an invalid parameter do nothing (return all products)",
         %{conn: conn, product: product} do
      params = %{"random_parameter" => "random_parameter"}

      conn = get(conn, ~p"/api/v1/products/products", params)

      assert json_response(conn, 200)["data"] == [
               product |> to_normalised_json()
             ]
    end

    @tag :product_controller
    test "allowed filters can be combined and return corresponding products",
         %{conn: conn, product: _product} do
      category_id = category_fixture().id
      manufacturer_id = manufacturer_fixture().id
      product_2 = product_fixture(%{category_id: category_id})

      product_3 =
        product_fixture(%{
          category_id: category_id,
          manufacturer_id: manufacturer_id
        })

      params = %{
        "product_ids" => "[#{product_2.id}, #{product_3.id}]",
        "category_id" => "#{category_id}",
        "manufacturer_id" => "#{manufacturer_id}"
      }

      conn = get(conn, ~p"/api/v1/products/products", params)

      assert json_response(conn, 200)["data"] == [
               product_3 |> to_normalised_json()
             ]
    end
  end

  describe "create product" do
    setup [:register_and_log_in_user, :make_user_admin]

    @tag :product_controller
    test "renders a product when data is valid", %{conn: conn} do
      product = product_valid_attrs()
      conn = post(conn, ~p"/api/v1/products/products", product: product)

      assert %{"id" => id} = json_response(conn, 201)["data"]

      # Recycle the connection so we can reuse it for a request.
      conn = recycle(conn)

      conn = get(conn, ~p"/api/v1/products/products/#{id}")

      product = Product.get!(id)

      assert json_response(conn, 200)["data"] ==
               product |> to_normalised_json()
    end

    @tag :product_controller
    test "handle product many_to_many relations creation (which are currently
    not in the JSON render)",
         %{conn: conn} do
      parts = create_parts()
      part_ids = create_part_ids(parts)
      notification_templates = create_notification_templates()

      notification_template_ids =
        create_notification_template_ids(notification_templates)

      product =
        product_valid_attrs()
        |> Map.put(:part_ids, part_ids)
        |> Map.put(:notification_template_ids, notification_template_ids)

      conn = post(conn, ~p"/api/v1/products/products", product: product)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      product = Product.get!(id)
      assert product.parts[:id] == parts[:id]
      assert product.notification_templates[:id] == notification_templates[:id]
    end

    @tag :product_controller
    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/products/products", product: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update product" do
    setup [:register_and_log_in_user, :create_product, :make_user_admin]

    @tag :product_controller
    test "renders product when data is valid", %{
      conn: conn,
      product: %Product{id: id} = product
    } do
      conn =
        put(conn, ~p"/api/v1/products/products/#{product}",
          product: @update_attrs
        )

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      # Recycle the connection so we can reuse it for a request.
      conn = recycle(conn)

      conn = get(conn, ~p"/api/v1/products/products/#{id}")

      product = Product.get!(id)

      assert json_response(conn, 200)["data"] ==
               product |> to_normalised_json()
    end

    @tag :product_controller
    test "updates product many_to_many relations (which are currently not in the
    JSON render)",
         %{
           conn: conn,
           product: %Product{id: id} = product
         } do
      new_parts = create_parts()
      new_part_ids = create_part_ids(new_parts)
      new_notification_templates = create_notification_templates()

      new_notification_template_ids =
        create_notification_template_ids(new_notification_templates)

      update_attrs =
        @update_attrs
        |> Map.put(:part_ids, new_part_ids)
        |> Map.put(
          :notification_template_ids,
          new_notification_template_ids
        )

      conn =
        put(conn, ~p"/api/v1/products/products/#{product}",
          product: update_attrs
        )

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      product = Product.get!(id)
      assert product.parts[:id] == new_parts[:id]

      assert product.notification_templates[:id] ==
               new_notification_templates[:id]
    end

    @tag :product_controller
    test "renders errors when data is invalid", %{
      conn: conn,
      product: product
    } do
      conn =
        put(conn, ~p"/api/v1/products/products/#{product}",
          product: @invalid_attrs
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete product" do
    setup [:register_and_log_in_user, :create_product, :make_user_admin]

    @tag :product_controller
    test "delete chosen product", %{conn: conn, product: product} do
      conn = delete(conn, ~p"/api/v1/products/products/#{product}")
      assert response(conn, 204)

      # Recycle the connection so we can reuse it for a request.
      conn = recycle(conn)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/v1/products/products/#{product}")
      end
    end
  end
end
