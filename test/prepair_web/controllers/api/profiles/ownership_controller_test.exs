defmodule PrepairWeb.Api.Profiles.OwnershipControllerTest do
  use PrepairWeb.ConnCase

  alias Prepair.Repo
  alias PrepairWeb.Api.Profiles.OwnershipJSON

  import Prepair.ProfilesFixtures

  @update_attrs %{
    price_of_purchase: 500,
    date_of_purchase: "2020-01-01",
    warranty_duration_m: 48
  }

  @invalid_attrs %{
    product_id: nil,
    date_of_purchase: nil
  }

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

  setup [:create_and_set_api_key, :register_and_log_in_user]

  describe "GET /api/v1/profiles/ownerships/by_profile/:id" do
    test "get the full list of ownerships for the given profile :id,
    when :id is the currently authenticated user",
         %{conn: conn, user: user} do
      id = user.id

      other_profile_id = profile_fixture().id

      private_ownership = create_private_ownership(id)
      public_ownership = create_public_ownership(id)
      _third_ownership = create_public_ownership(other_profile_id)

      conn = get(conn, ~p"/api/v1/profiles/ownerships/by_profile/#{id}")

      assert json_response(conn, 200)["data"] == [
               private_ownership |> to_normalised_json(),
               public_ownership |> to_normalised_json()
             ]
    end

    test "get only the public ownerships for the given profile :id,
    when :id is not the currently authenticated user",
         %{conn: conn, user: _user} do
      id = profile_fixture().id
      other_profile_id = profile_fixture().id

      _private_ownership = create_private_ownership(id)
      public_ownership = create_public_ownership(id)
      _third_ownership = create_public_ownership(other_profile_id)

      conn = get(conn, ~p"/api/v1/profiles/ownerships/by_profile/#{id}")

      assert json_response(conn, 200)["data"] == [
               public_ownership |> to_normalised_json()
             ]
    end
  end

  describe "GET /api/v1/profiles/ownerships/{id}" do
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
        Prepair.Profiles.get_ownership!(id)
        |> Repo.preload([:profile, :product, product: :manufacturer])

      assert json_response(conn, 200)["data"] ==
               ownership |> to_normalised_json()
    end

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
        Prepair.Profiles.get_ownership!(id)
        |> Repo.preload([[:profile, :product, product: :manufacturer]])

      assert json_response(conn, 200)["data"] ==
               ownership |> to_normalised_json()
    end

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
