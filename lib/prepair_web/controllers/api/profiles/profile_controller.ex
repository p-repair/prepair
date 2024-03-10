defmodule PrepairWeb.Api.Profiles.ProfileController do
  use PrepairWeb, :controller

  alias Prepair.Profiles
  alias Prepair.Profiles.Profile
  alias Prepair.Repo

  action_fallback PrepairWeb.Api.FallbackController

  def index(conn, _params) do
    profiles =
      Profiles.list_profiles()
      |> Repo.preload(:user)

    render(conn, :index, profiles: profiles)
  end

  def show(conn, %{"id" => id}) do
    profile =
      Profiles.get_profile!(id)

    render(conn, :show, profile: profile)
  end

  def update(conn, %{"id" => id, "profile" => profile_params}) do
    profile = Profiles.get_profile!(id)

    # Trick to avoid empty fields returned by FlutterFlow when value isn't changed.
    profile_params =
      Map.filter(profile_params, fn {_key, val} -> val != "" end)

    with {:ok, %Profile{} = profile} <-
           Profiles.update_profile(profile, profile_params) do
      render(conn, :show, profile: profile)
    end
  end
end
