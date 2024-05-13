defmodule PrepairWeb.Api.Profiles.OwnershipControllerTest do
  use PrepairWeb.ConnCase

  alias Prepair.Repo
  alias PrepairWeb.Api.Profiles.OwnershipJSON

  import Prepair.LegacyContexts.ProfilesFixtures
  import PrepairWeb.AuthorizationTestsMacro

  # NOTE: params needed for authorization tests macros
  @group_name "profiles"
  @context_name "ownerships"
  @short_module "ownership"
  @object_name :ownership

  @update_attrs %{
    price_of_purchase: 500,
    date_of_purchase: "2020-01-01",
    warranty_duration_m: 48
  }

  @invalid_attrs %{
    product_id: nil,
    date_of_purchase: nil
  }

  defp create_third_party_private_ownership(_) do
    profile = profile_fixture()
    ownership = create_private_ownership(profile.id)

    %{ownership: ownership}
  end

  defp create_third_party_public_ownership(_) do
    profile = profile_fixture()
    ownership = create_public_ownership(profile.id)

    %{ownership: ownership}
  end

  defp create_self_ownership(%{user: user}) do
    ownership = create_private_ownership(user.id)
    %{ownership: ownership}
  end

  defp create_private_ownership(profile_id) do
    ownership_fixture(profile_id)
    |> Repo.preload([:profile, :product, product: :manufacturer])
  end

  defp create_public_ownership(profile_id) do
    ownership_fixture(profile_id, %{public: true})
    |> Repo.preload([:profile, :product, product: :manufacturer])
  end

  defp to_normalised_json(data) do
    data
    |> OwnershipJSON.data()
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
    setup [:create_third_party_public_ownership]

    ######################## WHAT VISITORS CAN DO ? ############################

    # Nothing

    ####################### WHAT VISITORS CANNOT DO ? ##########################

    @tag :ownership_controller
    test_visitors_cannot_see_an_object()

    @tag :ownership_controller
    test_visitors_cannot_create_an_object()

    @tag :ownership_controller
    test_visitors_cannot_update_an_object()

    @tag :ownership_controller
    test_visitors_cannot_delete_an_object()

    @tag :ownership_controller
    test_index_route_does_not_exist()
  end

  ##############################################################################
  ########################### USERS - AUTHORIZATION ############################
  ##############################################################################
  describe "users authorization:" do
    setup [:register_and_log_in_user, :create_third_party_private_ownership]

    ########################### WHAT USERS CAN DO ? ############################

    @tag :ownership_controller
    test "users can see public ownerships from other users",
         %{conn: conn} do
      profile = profile_fixture()
      third_public_ownership = create_public_ownership(profile.id)

      conn =
        get(conn, ~p"/api/v1/profiles/ownerships/by_profile/#{profile.id}")

      assert json_response(conn, 200)["data"] ==
               [third_public_ownership |> to_normalised_json()]
    end

    ######################### WHAT USERS CANNOT DO ? ###########################

    @tag :ownership_controller
    test "users cannot see private ownerships from other users",
         %{conn: conn} do
      profile = profile_fixture()
      _third_private_ownership = create_private_ownership(profile.id)

      conn =
        get(conn, ~p"/api/v1/profiles/ownerships/by_profile/#{profile.id}")

      assert json_response(conn, 200)["data"] == []
    end

    @tag :ownership_controller
    test "users cannot create an ownership (for someone else)", %{conn: conn} do
      profile = profile_fixture()

      assert conn
             |> post(~p"/api/v1/profiles/ownerships", %{
               profile_id: profile.id,
               ownership: ownership_valid_attrs()
             })
             |> json_response(403)
    end

    @tag :ownership_controller
    test_users_cannot_see_an_object()

    @tag :ownership_controller
    test_users_cannot_update_an_object()

    @tag :ownership_controller
    test_users_cannot_delete_an_object()

    # Index route does not exist for ownerships (already tested with visitors).
  end

  ##############################################################################
  ############################ SELF - AUTHORIZATION ############################
  ##############################################################################
  describe "self authorization:" do
    setup [:register_and_log_in_user, :create_self_ownership]

    ############################ WHAT SELF CAN DO ? ############################

    @tag :ownership_controller
    test "self can list all its ownerships",
         %{conn: conn, user: user, ownership: ownership} do
      private_ownership = create_private_ownership(user.id)
      public_ownership = create_public_ownership(user.id)

      conn = get(conn, ~p"/api/v1/profiles/ownerships/by_profile/#{user.id}")

      assert json_response(conn, 200)["data"] == [
               ownership |> to_normalised_json(),
               private_ownership |> to_normalised_json(),
               public_ownership |> to_normalised_json()
             ]
    end

    @tag :ownership_controller
    test "self can create an ownership (for themselves)", %{
      conn: conn,
      user: user
    } do
      assert conn
             |> post(~p"/api/v1/profiles/ownerships", %{
               profile_id: user.id,
               ownership: ownership_valid_attrs()
             })
             |> json_response(201)
    end

    @tag :ownership_controller
    test_self_can_see_an_object()

    @tag :ownership_controller
    test_self_can_update_an_object()

    @tag :ownership_controller
    test_self_can_delete_an_object()

    ########################## WHAT SELF CANNOT DO ? ###########################

    # Index route does not exist for ownerships (already tested with visitors).
  end

  ##############################################################################
  ########################## FEATURES TESTS - ADMIN ############################
  ##############################################################################

  describe "GET /api/v1/profiles/ownerships/by_profile/:id" do
    setup [:register_and_log_in_user, :make_user_admin]

    @tag :ownership_controller
    test "get the full list of ownerships for the given profile",
         %{conn: conn, user: user} do
      private_ownership = create_private_ownership(user.id)
      public_ownership = create_public_ownership(user.id)

      conn = get(conn, ~p"/api/v1/profiles/ownerships/by_profile/#{user.id}")

      assert json_response(conn, 200)["data"] == [
               private_ownership |> to_normalised_json(),
               public_ownership |> to_normalised_json()
             ]
    end

    @tag :ownership_controller
    test "don't list other profile ownerships",
         %{conn: conn, user: user} do
      other_profile = profile_fixture()

      private_ownership = create_private_ownership(user.id)
      _third_ownership = create_public_ownership(other_profile.id)

      conn = get(conn, ~p"/api/v1/profiles/ownerships/by_profile/#{user.id}")

      assert json_response(conn, 200)["data"] ==
               [private_ownership |> to_normalised_json()]
    end
  end

  describe "GET /api/v1/profiles/ownerships/{id}" do
    setup [:register_and_log_in_user, :make_user_admin]

    @tag :ownership_controller
    test "get an ownership from its id", %{conn: conn, user: _user} do
      profile_id = profile_fixture().id
      private_ownership = create_private_ownership(profile_id)
      id = private_ownership.id

      conn = get(conn, ~p"/api/v1/profiles/ownerships/#{id}")

      assert json_response(conn, 200)["data"] ==
               private_ownership |> to_normalised_json()
    end
  end

  describe "POST /api/v1/profiles/ownerships" do
    setup [:register_and_log_in_user, :make_user_admin]

    @tag :ownership_controller
    test "creates an ownership when attrs are valid", %{
      conn: conn,
      user: _user
    } do
      profile_id = profile_fixture().id
      valid_attrs = ownership_valid_attrs()

      conn =
        post(conn, ~p"/api/v1/profiles/ownerships", %{
          profile_id: profile_id,
          ownership: valid_attrs
        })

      assert %{"id" => id} = json_response(conn, 201)["data"]

      # Recycle the connection so we can reuse it for a request.
      conn = recycle(conn)

      conn = get(conn, ~p"/api/v1/profiles/ownerships/#{id}")

      ownership =
        Prepair.LegacyContexts.Profiles.get_ownership!(id)
        |> Repo.preload([:profile, :product, product: :manufacturer])

      assert json_response(conn, 200)["data"] ==
               ownership |> to_normalised_json()
    end

    @tag :ownership_controller
    test "renders error when attrs are invalid", %{
      conn: conn,
      user: _user
    } do
      id = profile_fixture().id

      conn =
        post(conn, ~p"/api/v1/profiles/ownerships", %{
          profile_id: id,
          ownership: @invalid_attrs
        })

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "PUT /api/v1/profiles/ownerships/{:id}" do
    setup [:register_and_log_in_user, :make_user_admin]

    @tag :ownership_controller
    test "updates an ownership from its id when attrs are valid", %{
      conn: conn,
      user: _user
    } do
      id = ownership_fixture().id

      conn =
        put(conn, ~p"/api/v1/profiles/ownerships/#{id}", %{
          id: id,
          ownership: @update_attrs
        })

      assert %{"id" => id} = json_response(conn, 200)["data"]

      # Recycle the connection so we can reuse it for a request.
      conn = recycle(conn)

      conn = get(conn, ~p"/api/v1/profiles/ownerships/#{id}")

      ownership =
        Prepair.LegacyContexts.Profiles.get_ownership!(id)
        |> Repo.preload([[:profile, :product, product: :manufacturer]])

      assert json_response(conn, 200)["data"] ==
               ownership |> to_normalised_json()
    end

    @tag :ownership_controller
    test "renders error when attrs are invalid", %{
      conn: conn,
      user: _user
    } do
      id = ownership_fixture().id

      conn =
        put(conn, ~p"/api/v1/profiles/ownerships/#{id}", %{
          id: id,
          ownership: @invalid_attrs
        })

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete ownership" do
    setup [:register_and_log_in_user, :make_user_admin]

    @tag :ownership_controller
    test "delete chosen ownership", %{conn: conn, user: _user} do
      id = ownership_fixture().id

      conn = delete(conn, ~p"/api/v1/profiles/ownerships/#{id}")
      assert response(conn, 204)

      # Recycle the connection so we can reuse it for a request.
      conn = recycle(conn)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/v1/profiles/ownerships/#{id}")
      end
    end
  end
end
