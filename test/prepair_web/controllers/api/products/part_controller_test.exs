defmodule PrepairWeb.Api.Products.PartControllerTest do
  use PrepairWeb.ConnCase

  import Prepair.ProductsFixtures
  alias Prepair.Products.Part

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

  defp create_part(_) do
    part = part_fixture()
    %{part: part}
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  setup [:register_and_log_in_user]

  describe "index" do
    setup [:create_part]

    test "lists all parts", %{conn: conn, part: part} do
      conn = get(conn, ~p"/api/v1/products/parts")

      assert json_response(conn, 200)["data"] == [
               %{
                 "id" => part.id,
                 "category_id" => part.category.id,
                 "category_name" => part.category.name,
                 "manufacturer_id" => part.manufacturer.id,
                 "manufacturer_name" => part.manufacturer.name,
                 "name" => part.name,
                 "reference" => part.reference,
                 "description" => part.description,
                 "image" => part.image,
                 "average_lifetime_m" => part.average_lifetime_m,
                 "country_of_origin" => part.country_of_origin,
                 "start_of_production" =>
                   Date.to_string(part.start_of_production),
                 "end_of_production" => Date.to_string(part.end_of_production),
                 "main_material" => part.main_material
               }
             ]
    end
  end

  describe "create part" do
    test "renders a part when data is valid", %{conn: conn} do
      part = part_valid_attrs()
      part_category_id = part.category_id
      part_manufacturer_id = part.manufacturer_id
      part_reference = part.reference
      conn = post(conn, ~p"/api/v1/products/parts", part: part)

      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/v1/products/parts/#{id}")

      assert %{
               "category_id" => ^part_category_id,
               "manufacturer_id" => ^part_manufacturer_id,
               "name" => "some name",
               "reference" => ^part_reference,
               "description" => "some description",
               "image" => "some image",
               "average_lifetime_m" => 42,
               "country_of_origin" => "some country_of_origin",
               "start_of_production" => "2023-07-11",
               "end_of_production" => "2023-07-11"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/products/parts", part: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update part" do
    setup [:create_part]

    test "renders part when data is valid", %{
      conn: conn,
      part: %Part{id: id} = part
    } do
      %Part{category_id: category_id} = part
      %Part{manufacturer_id: manufacturer_id} = part

      conn = put(conn, ~p"/api/v1/products/parts/#{part}", part: @update_attrs)

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/v1/products/parts/#{id}")

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
      part: part
    } do
      conn = put(conn, ~p"/api/v1/products/parts/#{part}", part: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete part" do
    setup [:create_part]

    test "delete chosen part", %{conn: conn, part: part} do
      conn = delete(conn, ~p"/api/v1/products/parts/#{part}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/v1/products/parts/#{part}")
      end
    end
  end
end
