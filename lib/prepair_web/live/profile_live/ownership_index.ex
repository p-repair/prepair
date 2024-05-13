defmodule PrepairWeb.ProfileLive.OwnershipIndex do
  use PrepairWeb, :live_view

  alias Prepair.LegacyContexts.Profiles
  alias Prepair.Repo

  @impl true
  def mount(params, _session, socket) do
    current_user = socket.assigns.current_user
    profile_id = params["id"]
    profile_username = Profiles.get_profile!(profile_id).username

    socket =
      socket
      |> stream_configure(:ownerships,
        dom_id: &"ownerships-#{&1.id}"
      )

    case current_user.id == profile_id or current_user.role == :admin do
      true ->
        title =
          if current_user.role == :admin do
            gettext("Listing %{profile_username} Ownerships (admin view)",
              profile_username: profile_username
            )
          else
            gettext("Listing your Ownerships")
          end

        socket =
          socket
          |> assign(:title, title)
          |> stream(
            :ownerships,
            Profiles.list_ownerships_by_profile(profile_id,
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
            Profiles.list_ownerships_by_profile(profile_id)
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
