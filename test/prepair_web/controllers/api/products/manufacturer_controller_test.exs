defmodule PrepairWeb.Api.Products.ManufacturerControllerTest do
  use PrepairWeb.ConnCase

  import Prepair.ProductsFixtures
  alias Prepair.Products.Manufacturer
  alias PrepairWeb.Api.Products.ManufacturerJSON

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

  defp to_normalised_json(data) do
    data
    |> ManufacturerJSON.data()
    |> normalise_json()
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
               manufacturer |> to_normalised_json()
             ]
    end
  end

  describe "create manufacturer" do
    test "renders manufacturer when data is valid", %{conn: conn} do
      valid_attrs = manufacturer_valid_attrs()

      conn =
        post(conn, ~p"/api/v1/products/manufacturers",
          manufacturer: valid_attrs
        )

      assert %{"uuid" => uuid} = json_response(conn, 201)["data"]

      # Recycle the connection so we can reuse it for a request.
      conn = recycle(conn)

      conn = get(conn, ~p"/api/v1/products/manufacturers/#{uuid}")

      manufacturer = Prepair.Products.get_manufacturer!(uuid)

      assert json_response(conn, 200)["data"] ==
               manufacturer |> to_normalised_json()
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
      manufacturer: %Manufacturer{uuid: uuid} = manufacturer
    } do
      conn =
        put(conn, ~p"/api/v1/products/manufacturers/#{manufacturer}",
          manufacturer: @update_attrs
        )

      assert %{"uuid" => ^uuid} = json_response(conn, 200)["data"]

      # Recycle the connection so we can reuse it for a request.
      conn = recycle(conn)

      conn = get(conn, ~p"/api/v1/products/manufacturers/#{uuid}")

      manufacturer = Prepair.Products.get_manufacturer!(uuid)

      assert json_response(conn, 200)["data"] ==
               manufacturer |> to_normalised_json()
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
