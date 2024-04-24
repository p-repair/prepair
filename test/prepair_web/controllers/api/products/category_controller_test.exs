defmodule PrepairWeb.Api.Products.CategoryControllerTest do
  use PrepairWeb.ConnCase

  import Prepair.NotificationsFixtures
  import Prepair.ProductsFixtures
  import PrepairWeb.AuthorizationTestsMacro
  alias Prepair.Products
  alias Prepair.Products.Category
  alias PrepairWeb.Api.Products.CategoryJSON

  # NOTE: params needed for authorization tests macros
  @group_name "products"
  @context_name "categories"
  @short_module "category"
  @object_name :category

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

    notification_template_ids =
      create_notification_template_ids(notification_templates)

    category =
      category_fixture(%{
        notification_template_ids: notification_template_ids
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

  setup [:create_and_set_api_key]

  ##############################################################################
  ########################## VISITORS - AUTHORIZATION ##########################
  ##############################################################################
  describe "visitors authorization:" do
    ######################## WHAT VISITORS CAN DO ? ############################

    # Nothing

    ####################### WHAT VISITORS CANNOT DO ? ##########################

    setup [:create_category]

    @tag :category_controller
    test_visitors_cannot_list_objects()

    @tag :category_controller
    test_visitors_cannot_see_an_object()

    @tag :category_controller
    test_visitors_cannot_create_an_object()

    @tag :category_controller
    test_visitors_cannot_update_an_object()

    @tag :category_controller
    test_visitors_cannot_delete_an_object()
  end

  ##############################################################################
  ########################### USERS - AUTHORIZATION ############################
  ##############################################################################
  describe "users authorization:" do
    setup [:register_and_log_in_user, :create_category]

    ########################### WHAT USERS CAN DO ? ############################

    @tag :category_controller
    test_users_can_list_objects()

    @tag :category_controller
    test_users_can_see_an_object()

    @tag :category_controller
    test_users_can_create_an_object()

    ######################### WHAT USERS CANNOT DO ? ###########################

    @tag :category_controller
    test_users_cannot_update_an_object()

    @tag :category_controller
    test_users_cannot_delete_an_object()
  end

  ##############################################################################
  ########################## FEATURES TESTS - ADMIN ############################
  ##############################################################################

  describe "index" do
    setup [:register_and_log_in_user, :create_category, :make_user_admin]

    @tag :category_controller
    test "lists all categories", %{conn: conn, category: category} do
      conn = get(conn, ~p"/api/v1/products/categories")

      assert json_response(conn, 200)["data"] == [
               category |> to_normalised_json()
             ]
    end
  end

  describe "create category" do
    setup [:register_and_log_in_user, :make_user_admin]

    @tag :category_controller
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

    @tag :category_controller
    test "handle category many_to_many relations creation (which are currently
    not in the JSON render)",
         %{conn: conn} do
      notification_templates = create_notification_templates()

      notification_template_ids =
        create_notification_template_ids(notification_templates)

      category =
        category_valid_attrs()
        |> Map.put(:notification_template_ids, notification_template_ids)

      conn = post(conn, ~p"/api/v1/products/categories", category: category)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      category = Products.get_category!(id)
      assert category.notification_templates == notification_templates
    end

    @tag :category_controller
    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        post(conn, ~p"/api/v1/products/categories", category: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update category" do
    setup [:register_and_log_in_user, :create_category, :make_user_admin]

    @tag :category_controller
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

    @tag :category_controller
    test "updates category many_to_many relations (which are currently not in
    the JSON render)",
         %{
           conn: conn,
           category: %Category{id: id} = category
         } do
      new_notification_templates = create_notification_templates()

      new_notification_template_ids =
        create_notification_template_ids(new_notification_templates)

      update_attrs =
        @update_attrs
        |> Map.put(
          :notification_template_ids,
          new_notification_template_ids
        )

      conn =
        put(conn, ~p"/api/v1/products/categories/#{category}",
          category: update_attrs
        )

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      category = Products.get_category!(id)
      assert category.notification_templates == new_notification_templates
    end

    @tag :category_controller
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
    setup [:register_and_log_in_user, :create_category, :make_user_admin]

    @tag :category_controller
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
