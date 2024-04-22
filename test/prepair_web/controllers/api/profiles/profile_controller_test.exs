defmodule PrepairWeb.Api.Profiles.ProfileControllerTest do
  use PrepairWeb.ConnCase

  import Prepair.ProfilesFixtures
  import PrepairWeb.AuthorizationTestsMacro

  alias Prepair.Repo
  alias Prepair.Profiles
  alias PrepairWeb.Api.Profiles.ProfileJSON

  # NOTE: params needed for authorization tests macros
  @group_name "profiles"
  @context_name "profiles"
  @short_module "profile"
  @object_name :profile

  @update_attrs %{username: "some updated username"}

  @invalid_attrs %{username: nil}

  defp create_profile(_) do
    profile = profile_fixture()
    %{profile: profile}
  end

  defp get_own_profile(%{user: user}) do
    profile = Profiles.get_profile!(user.uuid)
    %{profile: profile}
  end

  defp to_normalised_json(data) do
    data
    |> ProfileJSON.data()
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
    setup [:create_profile]

    ######################## WHAT VISITORS CAN DO ? ############################

    # Nothing

    ####################### WHAT VISITORS CANNOT DO ? ##########################

    @tag :profile_controller
    test_visitors_cannot_list_objects()

    @tag :profile_controller
    test_visitors_cannot_see_an_object()

    @tag :profile_controller
    test_visitors_cannot_update_an_object()

    @tag :profile_controller
    test_create_route_does_not_exist()

    @tag :profile_controller
    test_delete_route_does_not_exist()
  end

  ##############################################################################
  ########################### USERS - AUTHORIZATION ############################
  ##############################################################################
  describe "users authorization:" do
    setup [:register_and_log_in_user, :create_profile]

    ########################### WHAT USERS CAN DO ? ############################

    # Nothing

    ######################### WHAT USERS CANNOT DO ? ###########################

    @tag :profile_controller
    test_users_cannot_list_objects()

    @tag :profile_controller
    test_users_cannot_see_an_object()

    @tag :profile_controller
    test_users_cannot_update_an_object()

    # Create route doesn’t exist for profiles (already tested with visitors).
    # Delete route doesn’t exist for profiles (already tested with visitors).
  end

  ##############################################################################
  ############################ SELF - AUTHORIZATION ############################
  ##############################################################################
  describe "self authorization:" do
    setup [:register_and_log_in_user, :get_own_profile]

    ############################ WHAT SELF CAN DO ? ############################

    @tag :profile_controller
    test_self_can_see_an_object()

    @tag :profile_controller
    test_self_can_update_an_object()

    ########################## WHAT SELF CANNOT DO ? ###########################

    @tag :profile_controller
    test_self_cannot_list_objects()

    # Create route doesn’t exist for profiles (already tested with visitors).
    # Delete route doesn’t exist for profiles (already tested with visitors).
  end

  ##############################################################################
  ########################## FEATURES TESTS - ADMIN ############################
  ##############################################################################

  describe "GET /api/v1/profiles/profile" do
    setup [:register_and_log_in_user, :make_user_admin]

    @tag :profile_controller
    test "get the list of all profiles", %{conn: conn, user: user} do
      profile = user.profile |> Repo.preload(:user)
      conn = get(conn, ~p"/api/v1/profiles/profiles")

      assert json_response(conn, 200)["data"] == [
               profile |> to_normalised_json()
             ]
    end
  end

  describe "POST /api/v1/profiles/profiles" do
    setup [:register_and_log_in_user, :make_user_admin]

    @tag :profile_controller
    test "renders error 404", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/profiles/profiles")

      assert json_response(conn, 404) == %{
               "errors" => [%{"detail" => "Not Found"}]
             }
    end
  end

  describe "GET /api/v1/profiles/profiles/{uuid}" do
    setup [:register_and_log_in_user, :make_user_admin]

    @tag :profile_controller
    test "get a profile from its uuid", %{conn: conn, user: user} do
      profile = user.profile |> Repo.preload(:user)
      uuid = profile.uuid
      conn = get(conn, ~p"/api/v1/profiles/profiles/#{uuid}")

      assert json_response(conn, 200)["data"] ==
               profile |> to_normalised_json()
    end
  end

  describe "PUT /api/v1/profiles/profiles/{uuid}" do
    setup [:register_and_log_in_user, :make_user_admin]

    @tag :profile_controller
    test "update a profile from its uuid when attrs are valid", %{
      conn: conn,
      user: user
    } do
      profile = user.profile |> Repo.preload(:user)
      uuid = profile.uuid

      conn =
        put(conn, ~p"/api/v1/profiles/profiles/#{uuid}", profile: @update_attrs)

      assert %{"uuid" => ^uuid} = json_response(conn, 200)["data"]

      # Recycle the connection so we can reuse it for a request.

      conn = recycle(conn)

      conn = get(conn, ~p"/api/v1/profiles/profiles/#{uuid}")

      profile = Prepair.Profiles.get_profile!(uuid)

      assert json_response(conn, 200)["data"] ==
               profile |> to_normalised_json()
    end

    @tag :profile_controller
    test "renders error when attrs are invalid", %{
      conn: conn,
      user: user
    } do
      profile = user.profile |> Repo.preload(:user)
      uuid = profile.uuid

      conn =
        put(conn, ~p"/api/v1/profiles/profiles/#{uuid}",
          profile: @invalid_attrs
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end
end
