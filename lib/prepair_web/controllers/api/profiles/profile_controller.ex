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

  def show(conn, %{"uuid" => uuid}) do
    profile =
      Profiles.get_profile!(uuid)

    render(conn, :show, profile: profile)
  end

  def update(conn, %{"uuid" => uuid, "profile" => profile_params}) do
    profile = Profiles.get_profile!(uuid)

    # Trick to avoid empty fields returned by FlutterFlow when value isn't changed.
    profile_params =
      Map.filter(profile_params, fn {_key, val} -> val != "" end)

    with {:ok, %Profile{} = profile} <-
           Profiles.update_profile(profile, profile_params) do
      render(conn, :show, profile: profile)
    end
  end
end
