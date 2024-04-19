defmodule PrepairWeb.ManufacturerLive.Index do
  use PrepairWeb, :live_view

  alias Prepair.Products
  alias Prepair.Products.Manufacturer
  alias PrepairWeb.UserAuth

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> stream_configure(:manufacturers,
        dom_id: &"manufacturers-#{&1.uuid}"
      )
      |> stream(:manufacturers, Products.list_manufacturers())

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"uuid" => uuid}) do
    page_title = gettext("Edit Manufacturer")

    socket
    |> assign(:page_title, page_title)
    |> assign(:manufacturer, Products.get_manufacturer!(uuid))
  end

  defp apply_action(socket, :new, _params) do
    page_title = gettext("New Manufacturer")

    socket
    |> assign(:page_title, page_title)
    |> assign(:manufacturer, %Manufacturer{})
  end

  defp apply_action(socket, :index, _params) do
    page_title = gettext("Listing Manufacturers")

    socket
    |> assign(:page_title, page_title)
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
  def handle_event("delete", %{"uuid" => uuid}, socket) do
    UserAuth.require_admin_and_do(socket, fn ->
      manufacturer = Products.get_manufacturer!(uuid)
      {:ok, _} = Products.delete_manufacturer(manufacturer)

      {:noreply, stream_delete(socket, :manufacturers, manufacturer)}
    end)
  end
end
