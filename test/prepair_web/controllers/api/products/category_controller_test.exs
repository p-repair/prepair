defmodule PrepairWeb.Api.Products.CategoryControllerTest do
  use PrepairWeb.ConnCase

  import Prepair.ProductsFixtures
  alias Prepair.Products.Category
  alias PrepairWeb.Api.Products.CategoryJSON

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

  defp to_normalised_json(data) do
    data
    |> CategoryJSON.data()
    |> normalise_json()
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  setup [:create_and_set_api_key, :register_and_log_in_user]

  describe "index" do
    setup [:create_category]

    test "lists all categories", %{conn: conn, category: category} do
      conn = get(conn, ~p"/api/v1/products/categories")

      assert json_response(conn, 200)["data"] == [
               category |> to_normalised_json()
             ]
    end
  end

  describe "create category" do
    test "renders a category when data is valid", %{conn: conn} do
      category = category_valid_attrs()
      conn = post(conn, ~p"/api/v1/products/categories", category: category)

      assert %{"id" => id} = json_response(conn, 201)["data"]

      # Recycle the connection so we can reuse it for a request.
      conn = recycle(conn)

      conn = get(conn, ~p"/api/v1/products/categories/#{id}")

      category = Prepair.Products.get_category!(id)

      assert json_response(conn, 200)["data"] ==
               category |> to_normalised_json()
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        post(conn, ~p"/api/v1/products/categories", category: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update category" do
    setup [:create_category]

    test "renders category when data is valid", %{
      conn: conn,
      category: %Category{id: id} = category
    } do
      conn =
        put(conn, ~p"/api/v1/products/categories/#{category}",
          category: @update_attrs
        )

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      # Recycle the connection so we can reuse it for a request.
      conn = recycle(conn)

      conn = get(conn, ~p"/api/v1/products/categories/#{id}")

      category = Prepair.Products.get_category!(id)

      assert json_response(conn, 200)["data"] ==
               category |> to_normalised_json()
    end

    test "renders errors when data is invalid", %{
      conn: conn,
      category: category
    } do
      conn =
        put(conn, ~p"/api/v1/products/categories/#{category}",
          category: @invalid_attrs
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete category" do
    setup [:create_category]

    test "delete chosen category", %{conn: conn, category: category} do
      conn = delete(conn, ~p"/api/v1/products/categories/#{category}")
      assert response(conn, 204)

      # Recycle the connection so we can reuse it for a request.
      conn = recycle(conn)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/v1/products/categories/#{category}")
      end
    end
  end
end
