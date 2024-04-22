defmodule PrepairWeb.Api.Profiles.OwnershipController do
  use PrepairWeb, :controller

  alias Prepair.Profiles
  alias Prepair.Profiles.Ownership
  alias Prepair.Repo

  action_fallback PrepairWeb.Api.FallbackController

  def index_by_profile(conn, params) do
    current_user = conn.assigns.current_user
    profile_uuid = params["uuid"]

    if current_user.uuid == profile_uuid or current_user.role == :admin do
      ownerships =
        Profiles.list_ownerships_by_profile(profile_uuid, include_private: true)

      render(conn, :index, ownerships: ownerships)
    else
      ownerships =
        Profiles.list_ownerships_by_profile(profile_uuid)

      render(conn, :index, ownerships: ownerships)
    end
  end

  def create(conn, %{
        "profile_uuid" => profile_uuid,
        "ownership" => ownership_params
      }) do
    with {:ok, %Ownership{} = ownership} <-
           Profiles.create_ownership(profile_uuid, ownership_params),
         ownership <- Repo.preload(ownership, [:profile, :product]) do
      conn
      |> put_status(:created)
      |> put_resp_header(
        "location",
        ~p"/api/v1/profiles/ownerships/#{ownership}"
      )
      |> render(:show, ownership: ownership)
    end
  end

  def show(conn, %{"uuid" => uuid}) do
    ownership = Profiles.get_ownership!(uuid)
    render(conn, :show, ownership: ownership)
  end

  def update(conn, %{"uuid" => uuid, "ownership" => ownership_params}) do
    ownership = Profiles.get_ownership!(uuid)

    # Trick to avoid empty fields returned by FlutterFlow when value isn't changed.
    ownership_params =
      Map.filter(ownership_params, fn {_key, val} -> val != "" end)

    with {:ok, %Ownership{} = ownership} <-
           Profiles.update_ownership(ownership, ownership_params) do
      render(conn, :show, ownership: ownership)
    end
  end

  def delete(conn, %{"uuid" => uuid}) do
    ownership = Profiles.get_ownership!(uuid)

    with {:ok, %Ownership{}} <-
           Profiles.delete_ownership(ownership) do
      send_resp(conn, :no_content, "")
    end
  end
end
