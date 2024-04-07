defmodule PrepairWeb.ProfileLive.Show do
  use PrepairWeb, :live_view

  alias Prepair.Profiles
  alias Prepair.Repo

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"uuid" => uuid}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:profile, uuid |> Profiles.get_profile!() |> Repo.preload(:user))}
  end

  defp page_title(:show), do: gettext("Show Profile")
  defp page_title(:edit), do: gettext("Edit Profile")
end
