defmodule PrepairWeb.Api.Profiles.OwnershipController do
  use PrepairWeb, :controller

  alias Prepair.Profiles
  alias Prepair.Profiles.Ownership
  alias Prepair.Repo

  action_fallback PrepairWeb.Api.FallbackController

  def index_by_profile(conn, params) do
    current_user_id = conn.assigns.current_user.id
    profile_id = params["id"] |> String.to_integer()

    if current_user_id == profile_id do
      ownerships =
        Profiles.list_ownerships_by_profile(profile_id)

      render(conn, :index, ownerships: ownerships)
    else
      ownerships =
        Profiles.list_ownerships_by_profile(profile_id, public: true)

      render(conn, :index, ownerships: ownerships)
    end
  end

  def create(conn, %{
        "profile_id" => profile_id,
        "ownership" => ownership_params
      }) do
    with {:ok, %Ownership{} = ownership} <-
           Profiles.create_ownership(profile_id, ownership_params),
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

  def show(conn, %{"id" => id}) do
    ownership = Profiles.get_ownership!(id)
    render(conn, :show, ownership: ownership)
  end

  def update(conn, %{"id" => id, "ownership" => ownership_params}) do
    ownership = Profiles.get_ownership!(id)

    # Trick to avoid empty fields returned by FlutterFlow when value isn't changed.
    ownership_params =
      Map.filter(ownership_params, fn {_key, val} -> val != "" end)

    with {:ok, %Ownership{} = ownership} <-
           Profiles.update_ownership(ownership, ownership_params) do
      render(conn, :show, ownership: ownership)
    end
  end

  def delete(conn, %{"id" => id}) do
    ownership = Profiles.get_ownership!(id)

    with {:ok, %Ownership{}} <-
           Profiles.delete_ownership(ownership) do
      send_resp(conn, :no_content, "")
    end
  end
end
