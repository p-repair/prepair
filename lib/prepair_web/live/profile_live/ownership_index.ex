defmodule PrepairWeb.ProfileLive.OwnershipIndex do
  use PrepairWeb, :live_view

  alias Prepair.Profiles
  alias Prepair.Repo

  @impl true
  def mount(params, _session, socket) do
    user_uuid = socket.assigns.current_user.uuid
    profile_uuid = params["uuid"]
    profile_username = Profiles.get_profile!(profile_uuid).username

    socket =
      socket
      |> stream_configure(:ownerships,
        dom_id: &"ownerships-#{&1.uuid}"
      )

    case user_uuid == profile_uuid do
      true ->
        title = gettext("Listing your Ownerships")

        socket =
          socket
          |> assign(:title, title)
          |> stream(
            :ownerships,
            Profiles.list_ownerships_by_profile(profile_uuid,
              include_private: true
            )
            |> Repo.preload([:product, :profile])
          )

        {:ok, socket}

      false ->
        title =
          gettext("Listing %{profile_username} public Ownerships",
            profile_username: profile_username
          )

        socket =
          socket
          |> assign(:title, title)
          |> stream(
            :ownerships,
            Profiles.list_ownerships_by_profile(profile_uuid)
            |> Repo.preload([:product, :profile])
          )

        {:ok, socket}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  def apply_action(socket, :index, _params) do
    page_title = gettext("Listing Public Ownerships")

    socket
    |> assign(:page_title, page_title)
    |> assign(:ownership, nil)
  end
end
