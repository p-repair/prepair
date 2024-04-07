defmodule PrepairWeb.Api.Products.CategoryControllerTest do
  use PrepairWeb.ConnCase

  import Prepair.NotificationsFixtures
  import Prepair.ProductsFixtures
  alias Prepair.Products
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
    notification_templates = create_notification_templates()

    notification_template_uuids =
      create_notification_template_uuids(notification_templates)

    category =
      category_fixture(%{
        notification_template_uuids: notification_template_uuids
      })

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

      assert %{"uuid" => uuid} = json_response(conn, 201)["data"]

      # Recycle the connection so we can reuse it for a request.
      conn = recycle(conn)

      conn = get(conn, ~p"/api/v1/products/categories/#{uuid}")

      category = Prepair.Products.get_category!(uuid)

      assert json_response(conn, 200)["data"] ==
               category |> to_normalised_json()
    end

    test "handle category many_to_many relations creation (which are currently
    not in the JSON render)",
         %{conn: conn} do
      notification_templates = create_notification_templates()

      notification_template_uuids =
        create_notification_template_uuids(notification_templates)

      category =
        category_valid_attrs()
        |> Map.put(:notification_template_uuids, notification_template_uuids)

      conn = post(conn, ~p"/api/v1/products/categories", category: category)
      assert %{"uuid" => uuid} = json_response(conn, 201)["data"]

      category = Products.get_category!(uuid)
      assert category.notification_templates == notification_templates
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
      category: %Category{uuid: uuid} = category
    } do
      conn =
        put(conn, ~p"/api/v1/products/categories/#{category}",
          category: @update_attrs
        )

      assert %{"uuid" => ^uuid} = json_response(conn, 200)["data"]

      # Recycle the connection so we can reuse it for a request.
      conn = recycle(conn)

      conn = get(conn, ~p"/api/v1/products/categories/#{uuid}")

      category = Prepair.Products.get_category!(uuid)

      assert json_response(conn, 200)["data"] ==
               category |> to_normalised_json()
    end

    test "updates category many_to_many relations (which are currently not in
    the JSON render)",
         %{
           conn: conn,
           category: %Category{uuid: uuid} = category
         } do
      new_notification_templates = create_notification_templates()

      new_notification_template_uuids =
        create_notification_template_uuids(new_notification_templates)

      update_attrs =
        @update_attrs
        |> Map.put(
          :notification_template_uuids,
          new_notification_template_uuids
        )

      conn =
        put(conn, ~p"/api/v1/products/categories/#{category}",
          category: update_attrs
        )

      assert %{"uuid" => ^uuid} = json_response(conn, 200)["data"]

      category = Products.get_category!(uuid)
      assert category.notification_templates == new_notification_templates
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
