defmodule PrepairWeb.ManufacturerLive.Index do
  use PrepairWeb, :live_view

  alias Prepair.Products
  alias Prepair.Products.Manufacturer

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :manufacturers, Products.list_manufacturers())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Manufacturer")
    |> assign(:manufacturer, Products.get_manufacturer!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Manufacturer")
    |> assign(:manufacturer, %Manufacturer{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Manufacturers")
    |> assign(:manufacturer, nil)
  end

  @impl true
  def handle_info(
        {PrepairWeb.ManufacturerLive.FormComponent, {:saved, manufacturer}},
        socket
      ) do
    {:noreply, stream_insert(socket, :manufacturers, manufacturer)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    manufacturer = Products.get_manufacturer!(id)
    {:ok, _} = Products.delete_manufacturer(manufacturer)

    {:noreply, stream_delete(socket, :manufacturers, manufacturer)}
  end
end