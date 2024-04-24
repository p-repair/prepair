defmodule PrepairWeb.AuthorizationTestsMacro do
  use PrepairWeb.ConnCase
  import Prepair.ProductsFixtures
  import Prepair.ProfilesFixtures

  # -------------------------------------------------------------------------- #
  # ------------------------------ TEST MACROS ------------------------------- #
  # -------------------------------------------------------------------------- #

  @moduledoc """
  Do not forget to add the requested params in the caller module.

  Requested params are:
  @group_name --- type String
  @context_name --- type String
  @short_module --- type String
  @object_name --- type atom

  Example:
  @group_name "products"
  @context_name "categories"
  @short_module "category"
  @object_name :category
  """

  ##############################################################################
  ########################## VISITORS - AUTHORIZATION ##########################
  ##############################################################################

  # TODO: check how to define setups in macros, to avoid the need of
  # defining special module attributes in each module?

  ######################### WHAT VISITORS CAN DO ? #############################

  # Nothing

  ######################## WHAT VISITORS CANNOT DO ? ###########################

  defmacro test_visitors_cannot_list_objects() do
    quote do
      # Visitors cannot list objects.
      @tag :controllers_authorization
      @tag :controllers_visitor_authorization
      test "visitors CANNOT list #{@context_name}", %{conn: conn} do
        assert conn
               |> get(u_path(conn, "/api/v1/#{@group_name}/#{@context_name}"))
               |> json_response(401)
      end
    end
  end

  defmacro test_visitors_cannot_see_an_object() do
    quote do
      # Visitors cannot see an object.
      @tag :controllers_authorization
      @tag :controllers_visitor_authorization
      test "visitors CANNOT see a #{@short_module}", %{
        :conn => conn,
        @object_name => object
      } do
        assert conn
               |> get(
                 u_path(
                   conn,
                   "/api/v1/#{@group_name}/#{@context_name}/#{object.id}"
                 )
               )
               |> json_response(401)
      end
    end
  end

  defmacro test_visitors_cannot_create_an_object() do
    quote do
      # Visitors cannot create an object.
      @tag :controllers_authorization
      @tag :controllers_visitor_authorization
      test "visitors CANNOT create a #{@short_module}", %{conn: conn} do
        assert conn
               |> post(u_path(conn, "/api/v1/#{@group_name}/#{@context_name}"))
               |> json_response(401)
      end
    end
  end

  defmacro test_visitors_cannot_update_an_object() do
    quote do
      # Visitors cannot update an object.
      @tag :controllers_authorization
      @tag :controllers_visitor_authorization
      test "visitors CANNOT update a #{@short_module}", %{
        :conn => conn,
        @object_name => object
      } do
        assert conn
               |> put(
                 u_path(
                   conn,
                   "/api/v1/#{@group_name}/#{@context_name}/#{object.id}"
                 )
               )
               |> json_response(401)

        assert conn
               |> patch(
                 u_path(
                   conn,
                   "/api/v1/#{@group_name}/#{@context_name}/#{object.id}"
                 )
               )
               |> json_response(401)
      end
    end
  end

  defmacro test_visitors_cannot_delete_an_object() do
    quote do
      # Visitors cannote delete an object.
      @tag :controllers_authorization
      @tag :controllers_visitor_authorization
      test "visitors CANNOT delete a #{@short_module}", %{
        :conn => conn,
        @object_name => object
      } do
        assert conn
               |> delete(
                 u_path(
                   conn,
                   "/api/v1/#{@group_name}/#{@context_name}/#{object.id}"
                 )
               )
               |> json_response(401)
      end
    end
  end

  ##############################################################################
  ########################### USERS - AUTHORIZATION ############################
  ##############################################################################

  ############################ WHAT USERS CAN DO ? #############################

  defmacro test_users_can_list_objects() do
    quote do
      # Users can list objects.
      @tag :controllers_authorization
      @tag :controllers_user_authorization
      test "users CAN list #{@context_name}", %{conn: conn} do
        assert conn
               |> get(u_path(conn, "/api/v1/#{@group_name}/#{@context_name}"))
               |> json_response(200)
      end
    end
  end

  defmacro test_users_can_see_an_object() do
    quote do
      # Users can see an object.
      @tag :controllers_authorization
      @tag :controllers_user_authorization
      test "users CAN see a #{@short_module}",
           %{:conn => conn, @object_name => object} do
        assert conn
               |> get(
                 u_path(
                   conn,
                   "/api/v1/#{@group_name}/#{@context_name}/#{object.id}"
                 )
               )
               |> json_response(200)
      end
    end
  end

  defmacro test_users_can_create_an_object() do
    quote do
      # Users can create an object.
      @tag :controllers_authorization
      @tag :controllers_user_authorization
      test "users CAN create a #{@short_module}", %{conn: conn} do
        object_attrs = attrs(__MODULE__)

        assert conn
               |> post(
                 u_path(conn, "/api/v1/#{@group_name}/#{@context_name}"),
                 [{@object_name, object_attrs}]
               )
               |> json_response(201)
      end
    end
  end

  ########################## WHAT USERS CANNOT DO ? ############################

  defmacro test_users_cannot_list_objects() do
    quote do
      # Users cannot list objects.
      @tag :controllers_authorization
      @tag :controllers_user_authorization
      test "users CANNOT list #{@context_name}", %{conn: conn} do
        assert conn
               |> get(u_path(conn, "/api/v1/#{@group_name}/#{@context_name}"))
               |> json_response(403)
      end
    end
  end

  defmacro test_users_cannot_see_an_object() do
    quote do
      # Users can see an object.
      @tag :controllers_authorization
      @tag :controllers_user_authorization
      test "users CANNOT see a #{@short_module}",
           %{:conn => conn, @object_name => object} do
        assert conn
               |> get(
                 u_path(
                   conn,
                   "/api/v1/#{@group_name}/#{@context_name}/#{object.id}"
                 )
               )
               |> json_response(403)
      end
    end
  end

  defmacro test_users_cannot_create_an_object() do
    quote do
      # Users cannot update an object.
      @tag :controllers_authorization
      @tag :controllers_user_authorization
      test "users CANNOT create a #{@short_module}", %{conn: conn} do
        object_attrs = attrs(__MODULE__)

        assert conn
               |> post(
                 u_path(conn, "/api/v1/#{@group_name}/#{@context_name}"),
                 [{@object_name, object_attrs}]
               )
               |> json_response(403)
      end
    end
  end

  defmacro test_users_cannot_update_an_object() do
    quote do
      # Users cannot update an object.
      @tag :controllers_authorization
      @tag :controllers_user_authorization
      test "users CANNOT update a #{@short_module}", %{
        :conn => conn,
        @object_name => object
      } do
        assert conn
               |> put(
                 u_path(
                   conn,
                   "/api/v1/#{@group_name}/#{@context_name}/#{object.id}"
                 ),
                 %{@object_name => @update_attrs}
               )
               |> json_response(403)

        assert conn
               |> patch(
                 u_path(
                   conn,
                   "/api/v1/#{@group_name}/#{@context_name}/#{object.id}"
                 ),
                 %{@object_name => @update_attrs}
               )
               |> json_response(403)
      end
    end
  end

  defmacro test_users_cannot_delete_an_object() do
    quote do
      # Users cannot delete an object.
      @tag :controllers_authorization
      @tag :controllers_user_authorization
      test "users CANNOT delete a #{@short_module}", %{
        :conn => conn,
        :user => user,
        @object_name => object
      } do
        assert conn
               |> delete(
                 u_path(
                   conn,
                   "/api/v1/#{@group_name}/#{@context_name}/#{object.id}"
                 )
               )
               |> json_response(403)

        # Make user admin to verify the object has not been deleted.
        make_user_admin(%{user: user})

        assert conn
               |> get(
                 u_path(
                   conn,
                   "/api/v1/#{@group_name}/#{@context_name}/#{object.id}"
                 )
               )
               |> json_response(200)
      end
    end
  end

  ##############################################################################
  ############################ SELF - AUTHORIZATION ############################
  ##############################################################################

  ############################# WHAT SELF CAN DO ? #############################

  defmacro test_self_can_see_an_object() do
    quote do
      # Self can see an object.
      @tag :controllers_authorization
      @tag :controllers_user_authorization
      test "self CAN see their #{@short_module}",
           %{:conn => conn, @object_name => object} do
        assert conn
               |> get(
                 u_path(
                   conn,
                   "/api/v1/#{@group_name}/#{@context_name}/#{object.id}"
                 )
               )
               |> json_response(200)
      end
    end
  end

  @spec test_self_can_update_an_object() ::
          {:__block__, [], [{:@, [...], [...]} | {:test, [...], [...]}, ...]}
  defmacro test_self_can_update_an_object() do
    quote do
      # Self can see an object.
      @tag :controllers_authorization
      @tag :controllers_user_authorization
      test "self CAN update their #{@short_module}",
           %{:conn => conn, @object_name => object} do
        assert conn
               |> put(
                 u_path(
                   conn,
                   "/api/v1/#{@group_name}/#{@context_name}/#{object.id}"
                 ),
                 %{@object_name => @update_attrs}
               )
               |> json_response(200)

        assert conn
               |> patch(
                 u_path(
                   conn,
                   "/api/v1/#{@group_name}/#{@context_name}/#{object.id}"
                 ),
                 %{@object_name => @update_attrs}
               )
               |> json_response(200)
      end
    end
  end

  defmacro test_self_can_delete_an_object() do
    quote do
      # Self can delete an object.
      @tag :controllers_authorization
      @tag :controllers_user_authorization
      test "self CAN delete their #{@short_module}",
           %{:conn => conn, @object_name => object} do
        assert conn
               |> delete(
                 u_path(
                   conn,
                   "/api/v1/#{@group_name}/#{@context_name}/#{object.id}"
                 )
               )
               |> response(204)

        assert_error_sent 404, fn ->
          get(
            conn,
            u_path(
              conn,
              "/api/v1/#{@group_name}/#{@context_name}/#{object.id}"
            )
          )
        end
      end
    end
  end

  ############################ WHAT SELF CANNOT DO ? ###########################

  defmacro test_self_cannot_list_objects() do
    quote do
      # Self cannot list its objects.
      @tag :controllers_authorization
      @tag :controllers_user_authorization
      test "users CANNOT list #{@context_name}", %{conn: conn} do
        assert conn
               |> get(u_path(conn, "/api/v1/#{@group_name}/#{@context_name}"))
               |> json_response(403)
      end
    end
  end

  ##############################################################################
  ############################# NOT EXISTING ROUTES ############################
  ##############################################################################

  defmacro test_index_route_does_not_exist() do
    quote do
      # Create route does not exist for module.
      @tag :controllers_authorization
      @tag :controllers_user_authorization
      test "index route does not exist for #{@short_module}",
           %{:conn => conn, @object_name => object} do
        assert conn
               |> get(
                 u_path(
                   conn,
                   "/api/v1/#{@group_name}/#{@context_name}"
                 )
               )
               |> response(404)
      end
    end
  end

  defmacro test_create_route_does_not_exist() do
    quote do
      # Create route does not exist for module.
      @tag :controllers_authorization
      @tag :controllers_user_authorization
      test "create route does not exist for #{@short_module}",
           %{:conn => conn, @object_name => object} do
        assert conn
               |> post(
                 u_path(
                   conn,
                   "/api/v1/#{@group_name}/#{@context_name}"
                 )
               )
               |> response(404)
      end
    end
  end

  defmacro test_delete_route_does_not_exist() do
    quote do
      # Delete route does not exist for module.
      @tag :controllers_authorization
      @tag :controllers_user_authorization
      test "delete route does not exist for #{@short_module}",
           %{:conn => conn, @object_name => object} do
        assert conn
               |> delete(
                 u_path(
                   conn,
                   "/api/v1/#{@group_name}/#{@context_name}/#{object.id}"
                 )
               )
               |> response(404)
      end
    end
  end

  # -------------------------------------------------------------------------- #
  # ---------------------------- HELPER FUNCTIONS ---------------------------- #
  # -------------------------------------------------------------------------- #

  def attrs(module) do
    case module do
      PrepairWeb.Api.Products.CategoryControllerTest ->
        category_valid_attrs()

      PrepairWeb.Api.Products.ManufacturerControllerTest ->
        manufacturer_valid_attrs()

      PrepairWeb.Api.Products.ProductControllerTest ->
        product_valid_attrs()

      PrepairWeb.Api.Products.PartControllerTest ->
        part_valid_attrs()

      PrepairWeb.Api.Profiles.ProfileControllerTest ->
        profile_valid_attrs()

        # PrepairWeb.Api.Profiles.OwnershipControllerTest ->
        #   ownership_valid_attrs()
    end
  end

  def u_path(conn, path), do: unverified_path(conn, PrepairWeb.Router, path)
end
