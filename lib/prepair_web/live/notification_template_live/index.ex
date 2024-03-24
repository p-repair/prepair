defmodule PrepairWeb.NotificationTemplateLive.Index do
  use PrepairWeb, :live_view

  alias Prepair.Notifications
  alias Prepair.Notifications.NotificationTemplate

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :notification_templates, Notifications.list_notification_templates())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Notification template")
    |> assign(:notification_template, Notifications.get_notification_template!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Notification template")
    |> assign(:notification_template, %NotificationTemplate{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Notification templates")
    |> assign(:notification_template, nil)
  end

  @impl true
  def handle_info({PrepairWeb.NotificationTemplateLive.FormComponent, {:saved, notification_template}}, socket) do
    {:noreply, stream_insert(socket, :notification_templates, notification_template)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    notification_template = Notifications.get_notification_template!(id)
    {:ok, _} = Notifications.delete_notification_template(notification_template)

    {:noreply, stream_delete(socket, :notification_templates, notification_template)}
  end
end
