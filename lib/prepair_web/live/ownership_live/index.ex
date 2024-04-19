defmodule PrepairWeb.OwnershipLive.Index do
  use PrepairWeb, :live_view

  alias Prepair.Profiles
  alias Prepair.Profiles.Ownership
  alias Prepair.Repo
  alias PrepairWeb.UserAuth

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

  defp apply_action(socket, :edit, %{"uuid" => uuid} = params) do
    UserAuth.require_self_and_do(:ownership, socket, params, fn ->
      page_title = gettext("Edit Ownership")

      socket
      |> assign(:page_title, page_title)
      |> assign(:ownership, Profiles.get_ownership!(uuid))
    end)
  end

  defp apply_action(socket, :new, _params) do
    page_title = gettext("New Ownership")

    socket
    |> assign(:page_title, page_title)
    |> assign(:ownership, %Ownership{})
  end

  defp apply_action(socket, :index, _params) do
    page_title = gettext("Listing Public Ownerships")

    socket
    |> assign(:page_title, page_title)
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
  def handle_event("delete", %{"uuid" => uuid} = params, socket) do
    UserAuth.require_self_and_do(:ownership, socket, params, fn ->
      ownership = Profiles.get_ownership!(uuid)
      {:ok, _} = Profiles.delete_ownership(ownership)

      {:noreply, stream_delete(socket, :ownerships, ownership)}
    end)
  end
end
