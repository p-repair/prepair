defmodule PrepairWeb.OwnershipLive.Index do
  use PrepairWeb, :live_view

  alias Prepair.Profiles
  alias Prepair.Profiles.Ownership
  alias Prepair.Repo

  @impl true
  def mount(_params, _session, socket) do
    ownerships =
      Profiles.list_ownerships()
      |> Repo.preload([:product, :profile])

    socket =
      socket
      |> stream_configure(:ownerships,
        dom_id: &"ownerships-#{&1.uuid}"
      )
      |> stream(:ownerships, ownerships)

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"uuid" => uuid}) do
    socket
    |> assign(:page_title, "Edit Ownership")
    |> assign(:ownership, Profiles.get_ownership!(uuid))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Ownership")
    |> assign(:ownership, %Ownership{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Public Ownerships")
    |> assign(:ownership, nil)
  end

  @impl true
  def handle_info(
        {PrepairWeb.OwnershipLive.FormComponent, {:saved, ownership}},
        socket
      ) do
    {:noreply, stream_insert(socket, :ownerships, ownership)}
  end

  @impl true
  def handle_event("delete", %{"uuid" => uuid}, socket) do
    ownership = Profiles.get_ownership!(uuid)
    {:ok, _} = Profiles.delete_ownership(ownership)

    {:noreply, stream_delete(socket, :ownerships, ownership)}
  end
end
