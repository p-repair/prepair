defmodule PrepairWeb.OwnershipLive.Show do
  use PrepairWeb, :live_view

  alias Prepair.Profiles
  alias Prepair.Repo

  @impl true
  def mount(_params, _session, socket) do
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

  defp page_title(:show), do: "Show Ownership"
  defp page_title(:edit), do: "Edit Ownership"
end
