defmodule PrepairWeb.PartLive.Index do
  use PrepairWeb, :live_view

  alias Prepair.Products
  alias Prepair.Products.Part

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :parts, Products.list_parts())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Part")
    |> assign(:part, Products.get_part!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Part")
    |> assign(:part, %Part{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Parts")
    |> assign(:part, nil)
  end

  @impl true
  def handle_info({PrepairWeb.PartLive.FormComponent, {:saved, part}}, socket) do
    {:noreply, stream_insert(socket, :parts, part)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    part = Products.get_part!(id)
    {:ok, _} = Products.delete_part(part)

    {:noreply, stream_delete(socket, :parts, part)}
  end
end
