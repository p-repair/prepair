defmodule PrepairWeb.NotificationTemplateLive.Show do
  use PrepairWeb, :live_view

  alias Prepair.Notifications

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"uuid" => uuid}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(
       :notification_template,
       Notifications.get_notification_template!(uuid)
     )}
  end

  defp page_title(:show), do: "Show Notification template"
  defp page_title(:edit), do: "Edit Notification template"

  defp names(item) do
    item
    |> Enum.map(& &1.name)
    |> Enum.join(", ")
  end
end
