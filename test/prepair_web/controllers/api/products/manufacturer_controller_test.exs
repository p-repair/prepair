defmodule PrepairWeb.Api.Products.ManufacturerControllerTest do
  use PrepairWeb.ConnCase

  import Prepair.ProductsFixtures
  alias Prepair.Products.Manufacturer

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

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  setup [:create_and_set_api_key, :register_and_log_in_user]

  describe "index" do
    setup [:create_manufacturer]

    test "lists all manufacturers", %{conn: conn, manufacturer: manufacturer} do
      conn = get(conn, ~p"/api/v1/products/manufacturers")

      assert json_response(conn, 200)["data"] == [
               %{
                 "id" => manufacturer.id,
                 "description" => manufacturer.description,
                 "image" => manufacturer.image,
                 "name" => manufacturer.name
               }
             ]
    end
  end

  describe "create manufacturer" do
    test "renders manufacturer when data is valid", %{conn: conn} do
      valid_attrs = manufacturer_valid_attrs()
      valid_name = valid_attrs.name

      conn =
        post(conn, ~p"/api/v1/products/manufacturers",
          manufacturer: valid_attrs
        )

      assert %{"id" => id} = json_response(conn, 201)["data"]

      # Recycle the connection so we can reuse it for a request.
      conn = recycle(conn)

      conn = get(conn, ~p"/api/v1/products/manufacturers/#{id}")

      assert %{
               "id" => ^id,
               "description" => "some description",
               "image" => "some image",
               "name" => ^valid_name
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        post(conn, ~p"/api/v1/products/manufacturers",
          manufacturer: @invalid_attrs
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update manufacturer" do
    setup [:create_manufacturer]

    test "renders manufacturer when data is valid", %{
      conn: conn,
      manufacturer: %Manufacturer{id: id} = manufacturer
    } do
      conn =
        put(conn, ~p"/api/v1/products/manufacturers/#{manufacturer}",
          manufacturer: @update_attrs
        )

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      # Recycle the connection so we can reuse it for a request.
      conn = recycle(conn)

      conn = get(conn, ~p"/api/v1/products/manufacturers/#{id}")

      assert %{
               "id" => ^id,
               "description" => "some updated description",
               "image" => "some updated image",
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{
      conn: conn,
      manufacturer: manufacturer
    } do
      conn =
        put(conn, ~p"/api/v1/products/manufacturers/#{manufacturer}",
          manufacturer: @invalid_attrs
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete manufacturer" do
    setup [:create_manufacturer]

    test "delete chosen manufacturer", %{conn: conn, manufacturer: manufacturer} do
      conn = delete(conn, ~p"/api/v1/products/manufacturers/#{manufacturer}")
      assert response(conn, 204)

      # Recycle the connection so we can reuse it for a request.
      conn = recycle(conn)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/v1/products/manufacturers/#{manufacturer}")
      end
    end
  end
end
