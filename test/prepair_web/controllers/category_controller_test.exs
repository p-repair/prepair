defmodule PrepairWeb.Api.Products.CategoryControllerTest do
  use PrepairWeb.ConnCase

  import Prepair.ProductsFixtures
  alias Prepair.Products.Category

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

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all categories", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/products/categories")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create category" do
    test "renders a category when data is valid", %{conn: conn} do
      category = category_valid_attrs()
      category_name = category.name
      conn = post(conn, ~p"/api/v1/products/categories", category: category)

      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/v1/products/categories/#{id}")

      assert %{
               "id" => ^id,
               "average_lifetime_m" => 42,
               "description" => "some description",
               "image" => "some image",
               "name" => ^category_name
             } = json_response(conn, 200)["data"]
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

      conn = get(conn, ~p"/api/v1/products/categories/#{id}")

      assert %{
               "id" => ^id,
               "average_lifetime_m" => 43,
               "description" => "some updated description",
               "image" => "some updated image",
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
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

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/v1/products/categories/#{category}")
      end
    end
  end
end
