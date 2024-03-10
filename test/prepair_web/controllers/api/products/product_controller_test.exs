defmodule PrepairWeb.Api.Products.ProductControllerTest do
  use PrepairWeb.ConnCase

  import Prepair.ProductsFixtures
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
    product = product_fixture()
    %{product: product}
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  setup [:create_and_set_api_key, :register_and_log_in_user]

  describe "index" do
    setup [:create_product]

    test "lists all products", %{conn: conn, product: product} do
      conn = get(conn, ~p"/api/v1/products/products")

      assert json_response(conn, 200)["data"] == [
               %{
                 "id" => product.id,
                 "category_id" => product.category.id,
                 "category_name" => product.category.name,
                 "manufacturer_id" => product.manufacturer.id,
                 "manufacturer_name" => product.manufacturer.name,
                 "name" => product.name,
                 "reference" => product.reference,
                 "description" => product.description,
                 "image" => product.image,
                 "average_lifetime_m" => product.average_lifetime_m,
                 "country_of_origin" => product.country_of_origin,
                 "start_of_production" =>
                   Date.to_string(product.start_of_production),
                 "end_of_production" =>
                   Date.to_string(product.end_of_production)
               }
             ]
    end
  end

  describe "index_by_category_and_manufacturer" do
    setup [:create_product]

    test "lists products from a given category and/or manufacturer", %{
      conn: conn,
      product: product
    } do
      cat_id = product.category_id
      man_id = product.manufacturer_id

      conn =
        get(
          conn,
          ~p"/api/v1/products/products/by_category_and_manufacturer/#{cat_id}/#{man_id}"
        )

      assert json_response(conn, 200)["data"] == [
               %{
                 "id" => product.id,
                 "category_id" => product.category.id,
                 "category_name" => product.category.name,
                 "manufacturer_id" => product.manufacturer.id,
                 "manufacturer_name" => product.manufacturer.name,
                 "name" => product.name,
                 "reference" => product.reference,
                 "description" => product.description,
                 "image" => product.image,
                 "average_lifetime_m" => product.average_lifetime_m,
                 "country_of_origin" => product.country_of_origin,
                 "start_of_production" =>
                   Date.to_string(product.start_of_production),
                 "end_of_production" =>
                   Date.to_string(product.end_of_production)
               }
             ]
    end

    test "don’t list products for category and manufacturer that not exists", %{
      conn: conn,
      product: _product
    } do
      cat_id = 0
      man_id = 0

      conn =
        get(
          conn,
          ~p"/api/v1/products/products/by_category_and_manufacturer/#{cat_id}/#{man_id}"
        )

      assert json_response(conn, 200)["data"] == []
    end

  end

  describe "create product" do
    test "renders a product when data is valid", %{conn: conn} do
      product = product_valid_attrs()
      product_category_id = product.category_id
      product_manufacturer_id = product.manufacturer_id
      product_reference = product.reference
      conn = post(conn, ~p"/api/v1/products/products", product: product)

      assert %{"id" => id} = json_response(conn, 201)["data"]

      # Recycle the connection so we can reuse it for a request.
      conn = recycle(conn)

      conn = get(conn, ~p"/api/v1/products/products/#{id}")

      assert %{
               "category_id" => ^product_category_id,
               "manufacturer_id" => ^product_manufacturer_id,
               "name" => "some name",
               "reference" => ^product_reference,
               "description" => "some description",
               "image" => "some image",
               "average_lifetime_m" => 42,
               "country_of_origin" => "some country_of_origin",
               "start_of_production" => "2023-07-11",
               "end_of_production" => "2023-07-11"
             } = json_response(conn, 200)["data"]
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
      product: %Product{id: id} = product
    } do
      %Product{category_id: category_id} = product
      %Product{manufacturer_id: manufacturer_id} = product

      conn =
        put(conn, ~p"/api/v1/products/products/#{product}",
          product: @update_attrs
        )

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      # Recycle the connection so we can reuse it for a request.
      conn = recycle(conn)

      conn = get(conn, ~p"/api/v1/products/products/#{id}")

      assert %{
               "id" => ^id,
               "category_id" => ^category_id,
               "manufacturer_id" => ^manufacturer_id,
               "name" => "some updated name",
               "reference" => "some updated reference",
               "description" => "some updated description",
               "image" => "some updated image",
               "average_lifetime_m" => 43,
               "country_of_origin" => "some updated country_of_origin",
               "start_of_production" => "2023-09-07",
               "end_of_production" => "2037-09-07"
             } = json_response(conn, 200)["data"]
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
