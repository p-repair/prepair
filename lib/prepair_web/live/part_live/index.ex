defmodule PrepairWeb.PartLive.Index do
  use PrepairWeb, :live_view

  alias Prepair.Products
  alias Prepair.Products.Part
  alias PrepairWeb.UserAuth

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> stream_configure(:parts,
        dom_id: &"parts-#{&1.uuid}"
      )
      |> stream(:parts, Products.list_parts())

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"uuid" => uuid}) do
    page_title = gettext("Edit Part")

    socket
    |> assign(:page_title, page_title)
    |> assign(:part, Products.get_part!(uuid))
  end

  defp apply_action(socket, :new, _params) do
    page_title = gettext("New Part")

    socket
    |> assign(:page_title, page_title)
    |> assign(:part, %Part{})
  end

  defp apply_action(socket, :index, _params) do
    page_title = gettext("Listing Parts")

    socket
    |> assign(:page_title, page_title)
    |> assign(:part, nil)
  end

  @impl true
  def handle_info({PrepairWeb.PartLive.FormComponent, {:saved, part}}, socket) do
    {:noreply, stream_insert(socket, :parts, part)}
  end

  @impl true
  def handle_event("delete", %{"uuid" => uuid}, socket) do
    UserAuth.require_admin_and_do(socket, fn ->
      part = Products.get_part!(uuid)
      {:ok, _} = Products.delete_part(part)

      {:noreply, stream_delete(socket, :parts, part)}
    end)
  end
end
