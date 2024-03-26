defmodule PrepairWeb.Api.Profiles.ProfileControllerTest do
  use PrepairWeb.ConnCase

  alias Prepair.Repo
  alias PrepairWeb.Api.Profiles.ProfileJSON

  @update_attrs %{username: "some updated username"}

  @invalid_attrs %{username: nil}

  defp to_normalised_json(data) do
    data
    |> ProfileJSON.data()
    |> normalise_json()
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  setup [:create_and_set_api_key, :register_and_log_in_user]

  describe "GET /api/v1/profiles/profile" do
    test "get the list of all profiles", %{conn: conn, user: user} do
      profile = user.profile |> Repo.preload(:user)
      conn = get(conn, ~p"/api/v1/profiles/profile")

      assert json_response(conn, 200)["data"] == [
               profile |> to_normalised_json()
             ]
    end
  end

  describe "POST /api/v1/profiles/profile" do
    test "renders error 404", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/profiles/profile")

      assert json_response(conn, 404) == %{
               "errors" => [%{"detail" => "Not Found"}]
             }
    end
  end

  describe "GET /api/v1/profiles/profile/{uuid}" do
    test "get a profile from its uuid", %{conn: conn, user: user} do
      profile = user.profile |> Repo.preload(:user)
      uuid = profile.uuid
      conn = get(conn, ~p"/api/v1/profiles/profile/#{uuid}")

      assert json_response(conn, 200)["data"] ==
               profile |> to_normalised_json()
    end
  end

  describe "PUT /api/v1/profiles/profile/{uuid}" do
    test "update a profile from its uuid when attrs are valid", %{
      conn: conn,
      user: user
    } do
      profile = user.profile |> Repo.preload(:user)
      uuid = profile.uuid

      conn =
        put(conn, ~p"/api/v1/profiles/profile/#{uuid}", profile: @update_attrs)

      assert %{"uuid" => ^uuid} = json_response(conn, 200)["data"]

      # Recycle the connection so we can reuse it for a request.

      conn = recycle(conn)

      conn = get(conn, ~p"/api/v1/profiles/profile/#{uuid}")

      profile = Prepair.Profiles.get_profile!(uuid)

      assert json_response(conn, 200)["data"] ==
               profile |> to_normalised_json()
    end

    test "renders error when attrs are invalid", %{
      conn: conn,
      user: user
    } do
      profile = user.profile |> Repo.preload(:user)
      uuid = profile.uuid

      conn =
        put(conn, ~p"/api/v1/profiles/profile/#{uuid}", profile: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end
end
