defmodule PrepairWeb.ProfileLive.Index do
  use PrepairWeb, :live_view

  alias Prepair.Profiles
  alias Prepair.Repo

  @impl true
  def mount(_params, _session, socket) do
    profiles =
      Profiles.list_profiles()
      |> Repo.preload(:user)
      |> Enum.sort_by(& &1.inserted_at, :asc)

    socket =
      socket
      |> stream_configure(:profiles,
        dom_id: &"profiles-#{&1.uuid}"
      )
      |> stream(:profiles, profiles)

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"uuid" => uuid}) do
    socket
    |> assign(:page_title, "Edit Profile")
    |> assign(:profile, uuid |> Profiles.get_profile!() |> Repo.preload(:user))
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Profiles")
    |> assign(:profile, nil)
  end

  @impl true
  def handle_info(
        {PrepairWeb.ProfileLive.FormComponent, {:saved, profile}},
        socket
      ) do
    {:noreply, stream_insert(socket, :profiles, profile)}
  end
end
