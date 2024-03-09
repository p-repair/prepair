defmodule PrepairWeb.Api.Profiles.ProfileControllerTest do
  use PrepairWeb.ConnCase

  alias Prepair.Repo

  @update_attrs %{username: "some updated username"}

  @invalid_attrs %{username: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  setup [:create_and_set_api_key, :register_and_log_in_user]

  describe "GET /api/v1/profiles/profile" do
    test "get the list of all profiles", %{conn: conn, user: user} do
      profile = user.profile |> Repo.preload(:user)
      conn = get(conn, ~p"/api/v1/profiles/profile")

      assert json_response(conn, 200)["data"] == [
               %{
                 "id" => profile.id,
                 "username" => profile.username,
                 "user_email" => profile.user.email,
                 "user_role" => to_string(profile.user.role),
                 "newsletter" => profile.newsletter,
                 "created_at" => DateTime.to_iso8601(profile.inserted_at)
               }
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

  describe "GET /api/v1/profiles/profile/{id}" do
    test "get a profile from its id", %{conn: conn, user: user} do
      profile = user.profile |> Repo.preload(:user)
      id = profile.id
      conn = get(conn, ~p"/api/v1/profiles/profile/#{id}")

      assert json_response(conn, 200)["data"] == %{
               "id" => profile.id,
               "username" => profile.username,
               "user_email" => profile.user.email,
               "user_role" => to_string(profile.user.role),
               "newsletter" => profile.newsletter,
               "created_at" => DateTime.to_iso8601(profile.inserted_at)
             }
    end
  end

  describe "PUT /api/v1/profiles/profile/{id}" do
    test "update a profile from its id when attrs are valid", %{
      conn: conn,
      user: user
    } do
      profile = user.profile |> Repo.preload(:user)
      id = profile.id

      conn =
        put(conn, ~p"/api/v1/profiles/profile/#{id}", profile: @update_attrs)

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      # Recycle the connection so we can reuse it for a request.

      conn = recycle(conn)

      conn = get(conn, ~p"/api/v1/profiles/profile/#{id}")

      assert json_response(conn, 200)["data"] == %{
               "id" => profile.id,
               "username" => "some updated username",
               "user_email" => profile.user.email,
               "user_role" => to_string(profile.user.role),
               "newsletter" => profile.newsletter,
               "created_at" => DateTime.to_iso8601(profile.inserted_at)
             }
    end

    test "renders error when attrs are invalid", %{
      conn: conn,
      user: user
    } do
      profile = user.profile |> Repo.preload(:user)
      id = profile.id

      conn =
        put(conn, ~p"/api/v1/profiles/profile/#{id}", profile: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end
end
