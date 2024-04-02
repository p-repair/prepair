defmodule PrepairWeb.Api.Products.ProductControllerTest do
  use PrepairWeb.ConnCase

  import Prepair.NotificationsFixtures
  import Prepair.ProductsFixtures
  alias Prepair.Products
  alias PrepairWeb.Api.Products.ProductJSON
  alias Prepair.Products.Product

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
    part_uuids = create_part_uuids(parts)
    notification_templates = create_notification_templates()

    notification_template_uuids =
      create_notification_template_uuids(notification_templates)

    product =
      product_fixture(%{
        part_uuids: part_uuids,
        notification_template_uuids: notification_template_uuids
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

  setup [:create_and_set_api_key, :register_and_log_in_user]

  describe "index" do
    setup [:create_product]

    test "lists all products when no query parameters are passed", %{
      conn: conn,
      product: product
    } do
      conn = get(conn, ~p"/api/v1/products/products")

      assert json_response(conn, 200)["data"] == [
               product |> to_normalised_json()
             ]
    end

    test "filter by product_uuids when :product_uuids is set in query parameters",
         %{conn: conn, product: product} do
      _product_2 = product_fixture()

      product_uuid = product.uuid
      params = %{"product_uuids" => "#{product_uuid}"}

      conn = get(conn, ~p"/api/v1/products/products", params)

      assert json_response(conn, 200)["data"] == [
               product |> to_normalised_json()
             ]
    end

    test "filter by category_uuid when :category_uuid is set in query parameters",
         %{conn: conn, product: _product} do
      category_uuid = category_fixture().uuid
      product_2 = product_fixture(%{category_uuid: category_uuid})

      params = %{"category_uuid" => "#{category_uuid}"}

      conn = get(conn, ~p"/api/v1/products/products", params)

      assert json_response(conn, 200)["data"] == [
               product_2 |> to_normalised_json()
             ]
    end

    test "filter by manufacturer_uuid when :manufacturer_uuid is set in query
    parameters",
         %{conn: conn, product: _product} do
      manufacturer_uuid = manufacturer_fixture().uuid
      product_2 = product_fixture(%{manufacturer_uuid: manufacturer_uuid})

      params = %{"manufacturer_uuid" => "#{manufacturer_uuid}"}

      conn = get(conn, ~p"/api/v1/products/products", params)

      assert json_response(conn, 200)["data"] == [
               product_2 |> to_normalised_json()
             ]
    end

    test "filter by an invalid parameter do nothing (return all products)",
         %{conn: conn, product: product} do
      params = %{"random_parameter" => "random_parameter"}

      conn = get(conn, ~p"/api/v1/products/products", params)

      assert json_response(conn, 200)["data"] == [
               product |> to_normalised_json()
             ]
    end

    test "allowed filters can be combined and return corresponding products",
         %{conn: conn, product: _product} do
      category_uuid = category_fixture().uuid
      manufacturer_uuid = manufacturer_fixture().uuid
      product_2 = product_fixture(%{category_uuid: category_uuid})

      product_3 =
        product_fixture(%{
          category_uuid: category_uuid,
          manufacturer_uuid: manufacturer_uuid
        })

      params = %{
        "product_uuids" => "[#{product_2.uuid}, #{product_3.uuid}]",
        "category_uuid" => "#{category_uuid}",
        "manufacturer_uuid" => "#{manufacturer_uuid}"
      }

      conn = get(conn, ~p"/api/v1/products/products", params)

      assert json_response(conn, 200)["data"] == [
               product_3 |> to_normalised_json()
             ]
    end
  end

  describe "create product" do
    test "renders a product when data is valid", %{conn: conn} do
      product = product_valid_attrs()
      conn = post(conn, ~p"/api/v1/products/products", product: product)

      assert %{"uuid" => uuid} = json_response(conn, 201)["data"]

      # Recycle the connection so we can reuse it for a request.
      conn = recycle(conn)

      conn = get(conn, ~p"/api/v1/products/products/#{uuid}")

      product = Prepair.Products.get_product!(uuid)

      assert json_response(conn, 200)["data"] ==
               product |> to_normalised_json()
    end

    test "handle product many_to_many relations creation (which are currently
    not in the JSON render)",
         %{conn: conn} do
      parts = create_parts()
      part_uuids = create_part_uuids(parts)
      notification_templates = create_notification_templates()

      notification_template_uuids =
        create_notification_template_uuids(notification_templates)

      product =
        product_valid_attrs()
        |> Map.put(:part_uuids, part_uuids)
        |> Map.put(:notification_template_uuids, notification_template_uuids)

      conn = post(conn, ~p"/api/v1/products/products", product: product)
      assert %{"uuid" => uuid} = json_response(conn, 201)["data"]

      product = Products.get_product!(uuid)
      assert product.parts == parts
      assert product.notification_templates == notification_templates
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/products/products", product: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update product" do
    setup [:create_product]

    test "renders product when data is valid", %{
      conn: conn,
      product: %Product{uuid: uuid} = product
    } do
      conn =
        put(conn, ~p"/api/v1/products/products/#{product}",
          product: @update_attrs
        )

      assert %{"uuid" => ^uuid} = json_response(conn, 200)["data"]

      # Recycle the connection so we can reuse it for a request.
      conn = recycle(conn)

      conn = get(conn, ~p"/api/v1/products/products/#{uuid}")

      product = Prepair.Products.get_product!(uuid)

      assert json_response(conn, 200)["data"] ==
               product |> to_normalised_json()
    end

    test "updates product many_to_many relations (which are currently not in the
    JSON render)",
         %{
           conn: conn,
           product: %Product{uuid: uuid} = product
         } do
      new_parts = create_parts()
      new_part_uuids = create_part_uuids(new_parts)
      new_notification_templates = create_notification_templates()

      new_notification_template_uuids =
        create_notification_template_uuids(new_notification_templates)

      update_attrs =
        @update_attrs
        |> Map.put(:part_uuids, new_part_uuids)
        |> Map.put(
          :notification_template_uuids,
          new_notification_template_uuids
        )

      conn =
        put(conn, ~p"/api/v1/products/products/#{product}",
          product: update_attrs
        )

      assert %{"uuid" => ^uuid} = json_response(conn, 200)["data"]

      product = Products.get_product!(uuid)
      assert product.parts == new_parts
      assert product.notification_templates == new_notification_templates
    end

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
    setup [:create_product]

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
