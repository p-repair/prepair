defmodule PrepairWeb.OwnershipLive.Show do
  use PrepairWeb, :live_view

  alias Prepair.LegacyContexts.Profiles
  alias Prepair.Repo
  alias PrepairWeb.UserAuth

  @impl true
  def mount(params, _session, socket) do
    socket =
      UserAuth.require_self_and_do(:ownership, socket, params, fn ->
        socket
      end)

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    ownership =
      Profiles.get_ownership!(id)
      |> Repo.preload([:product, :profile])

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:ownership, ownership)}
  end

  defp page_title(:show), do: gettext("Show Ownership")
  defp page_title(:edit), do: gettext("Edit Ownership")
end
