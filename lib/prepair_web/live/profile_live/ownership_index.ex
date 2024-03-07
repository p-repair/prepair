defmodule PrepairWeb.ProfileLive.OwnershipIndex do
  use PrepairWeb, :live_view

  alias Prepair.Profiles
  alias Prepair.Repo

  @impl true
  def mount(params, _session, socket) do
    user_id = socket.assigns.current_user.id
    profile_id = params["id"] |> String.to_integer()
    profile_username = Profiles.get_profile!(profile_id).username

    case user_id == profile_id do
      true ->
        socket =
          socket
          |> assign(:profile, "your")
          |> stream(
            :ownerships,
            Profiles.list_ownerships_by_profile(profile_id)
            |> Repo.preload([:product, :profile])
          )

        {:ok, socket}

      false ->
        socket =
          socket
          |> assign(:profile, "#{profile_username} public")
          |> stream(
            :ownerships,
            Profiles.list_ownerships_by_profile(profile_id, public: true)
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
    socket
    |> assign(:page_title, "Listing Public Ownerships")
    |> assign(:ownership, nil)
  end
end
