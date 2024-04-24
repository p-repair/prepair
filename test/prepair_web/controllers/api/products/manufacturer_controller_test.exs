defmodule PrepairWeb.Api.Products.ManufacturerControllerTest do
  use PrepairWeb.ConnCase

  import Prepair.ProductsFixtures
  import PrepairWeb.AuthorizationTestsMacro
  alias Prepair.Products.Manufacturer
  alias PrepairWeb.Api.Products.ManufacturerJSON

  # NOTE: params needed for authorization tests macros
  @group_name "products"
  @context_name "manufacturers"
  @short_module "manufacturer"
  @object_name :manufacturer

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

  setup [:create_and_set_api_key]

  ##############################################################################
  ########################## VISITORS - AUTHORIZATION ##########################
  ##############################################################################
  describe "visitors authorization:" do
    ######################## WHAT VISITORS CAN DO ? ############################

    # Nothing

    ####################### WHAT VISITORS CANNOT DO ? ##########################

    setup [:create_manufacturer]

    @tag :manufacturer_controller
    test_visitors_cannot_list_objects()

    @tag :manufacturer_controller
    test_visitors_cannot_see_an_object()

    @tag :manufacturer_controller
    test_visitors_cannot_create_an_object()

    @tag :manufacturer_controller
    test_visitors_cannot_update_an_object()

    @tag :manufacturer_controller
    test_visitors_cannot_delete_an_object()
  end

  ##############################################################################
  ########################### USERS - AUTHORIZATION ############################
  ##############################################################################
  describe "users authorization:" do
    setup [:register_and_log_in_user, :create_manufacturer]

    ########################### WHAT USERS CAN DO ? ############################

    @tag :manufacturer_controller
    test_users_can_list_objects()

    @tag :manufacturer_controller
    test_users_can_see_an_object()

    @tag :manufacturer_controller
    test_users_can_create_an_object()

    ######################### WHAT USERS CANNOT DO ? ###########################

    @tag :manufacturer_controller
    test_users_cannot_update_an_object()

    @tag :manufacturer_controller
    test_users_cannot_delete_an_object()
  end

  ##############################################################################
  ########################## FEATURES TESTS - ADMIN ############################
  ##############################################################################

  describe "index" do
    setup [:register_and_log_in_user, :create_manufacturer, :make_user_admin]

    @tag :manufacturer_controller
    test "lists all manufacturers", %{conn: conn, manufacturer: manufacturer} do
      conn = get(conn, ~p"/api/v1/products/manufacturers")

      assert json_response(conn, 200)["data"] == [
               manufacturer |> to_normalised_json()
             ]
    end
  end

  describe "create manufacturer" do
    setup [:register_and_log_in_user, :make_user_admin]

    @tag :manufacturer_controller
    test "renders manufacturer when data is valid", %{conn: conn} do
      valid_attrs = manufacturer_valid_attrs()

      conn =
        post(conn, ~p"/api/v1/products/manufacturers",
          manufacturer: valid_attrs
        )

      assert %{"id" => id} = json_response(conn, 201)["data"]

      # Recycle the connection so we can reuse it for a request.
      conn = recycle(conn)

      conn = get(conn, ~p"/api/v1/products/manufacturers/#{id}")

      manufacturer = Prepair.Products.get_manufacturer!(id)

      assert json_response(conn, 200)["data"] ==
               manufacturer |> to_normalised_json()
    end

    @tag :manufacturer_controller
    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        post(conn, ~p"/api/v1/products/manufacturers",
          manufacturer: @invalid_attrs
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update manufacturer" do
    setup [:register_and_log_in_user, :create_manufacturer, :make_user_admin]

    @tag :manufacturer_controller
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

      manufacturer = Prepair.Products.get_manufacturer!(id)

      assert json_response(conn, 200)["data"] ==
               manufacturer |> to_normalised_json()
    end

    @tag :manufacturer_controller
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
    setup [:register_and_log_in_user, :create_manufacturer, :make_user_admin]

    @tag :manufacturer_controller
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
