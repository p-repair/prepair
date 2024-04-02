defmodule PrepairWeb.PartLive.Show do
  use PrepairWeb, :live_view

  alias Prepair.Products

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"uuid" => uuid}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:part, Products.get_part!(uuid))}
  end

  defp page_title(:show), do: "Show Part"
  defp page_title(:edit), do: "Edit Part"
end
