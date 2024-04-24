defmodule PrepairWeb.ManufacturerLive.Show do
  use PrepairWeb, :live_view

  alias Prepair.Products

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:manufacturer, Products.get_manufacturer!(id))}
  end

  defp page_title(:show), do: gettext("Show Manufacturer")
  defp page_title(:edit), do: gettext("Edit Manufacturer")
end
