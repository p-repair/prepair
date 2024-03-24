defmodule PrepairWeb.Api.Products.PartControllerTest do
  use PrepairWeb.ConnCase

  import Prepair.NotificationsFixtures
  import Prepair.ProductsFixtures
  alias Prepair.Products
  alias Prepair.Products.Part
  alias PrepairWeb.Api.Products.PartJSON

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
    products = create_products()
    product_ids = create_product_ids(products)
    notification_templates = create_notification_templates()

    notification_template_ids =
      create_notification_template_ids(notification_templates)

    part =
      part_fixture(%{
        product_ids: product_ids,
        notification_template_ids: notification_template_ids
      })

    %{part: part}
  end

  defp to_normalised_json(data) do
    data
    |> PartJSON.data()
    |> normalise_json()
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  setup [:create_and_set_api_key, :register_and_log_in_user]

  describe "index" do
    setup [:create_part]

    test "lists all parts", %{conn: conn, part: part} do
      conn = get(conn, ~p"/api/v1/products/parts")

      assert json_response(conn, 200)["data"] == [
               part |> to_normalised_json()
             ]
    end
  end

  describe "create part" do
    test "renders a part when data is valid", %{conn: conn} do
      part = part_valid_attrs()
      conn = post(conn, ~p"/api/v1/products/parts", part: part)

      assert %{"id" => id} = json_response(conn, 201)["data"]

      # Recycle the connection so we can reuse it for a request.
      conn = recycle(conn)

      conn = get(conn, ~p"/api/v1/products/parts/#{id}")

      part = Prepair.Products.get_part!(id)

      assert json_response(conn, 200)["data"] == part |> to_normalised_json()
    end

    test "handle part many_to_many relations (which are currently not in the
    JSON render)",
         %{conn: conn} do
      products = create_products()
      product_ids = create_product_ids(products)
      notification_templates = create_notification_templates()

      notification_template_ids =
        create_notification_template_ids(notification_templates)

      part =
        part_valid_attrs()
        |> Map.put(:product_ids, product_ids)
        |> Map.put(:notification_template_ids, notification_template_ids)

      conn = post(conn, ~p"/api/v1/products/parts", part: part)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      part = Products.get_part!(id)
      assert part.products == products
      assert part.notification_templates == notification_templates
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
      conn = put(conn, ~p"/api/v1/products/parts/#{part}", part: @update_attrs)

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      # Recycle the connection so we can reuse it for a request.
      conn = recycle(conn)

      conn = get(conn, ~p"/api/v1/products/parts/#{id}")

      part = Prepair.Products.get_part!(id)

      assert json_response(conn, 200)["data"] == part |> to_normalised_json()
    end

    test "updates part many_to_many relations (which are currently not in the
    JSON render)",
         %{
           conn: conn,
           part: %Part{id: id} = part
         } do
      new_products = create_products()
      new_product_ids = create_product_ids(new_products)
      new_notification_templates = create_notification_templates()

      new_notification_template_ids =
        create_notification_template_ids(new_notification_templates)

      update_attrs =
        @update_attrs
        |> Map.put(:product_ids, new_product_ids)
        |> Map.put(:notification_template_ids, new_notification_template_ids)

      conn = put(conn, ~p"/api/v1/products/parts/#{part}", part: update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      part = Products.get_part!(id)
      assert part.products == new_products
      assert part.notification_templates == new_notification_templates
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

      # Recycle the connection so we can reuse it for a request.
      conn = recycle(conn)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/v1/products/parts/#{part}")
      end
    end
  end
end
