defmodule PrepairWeb.NotificationTemplateLive.Index do
  use PrepairWeb, :live_view

  alias Prepair.Notifications
  alias Prepair.Notifications.NotificationTemplate
  alias Prepair.Repo
  alias PrepairWeb.UserAuth

  @impl true
  def mount(_params, _session, socket) do
    notification_templates =
      Notifications.list_notification_templates()
      |> Repo.preload([:categories, :products, :parts])

    socket =
      socket
      |> stream_configure(:notification_templates,
        dom_id: &"notification_templates-#{&1.id}"
      )
      |> stream(
        :notification_templates,
        notification_templates
      )

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    page_title = gettext("Edit Notification template")

    socket
    |> assign(:page_title, page_title)
    |> assign(
      :notification_template,
      Notifications.get_notification_template!(id)
    )
  end

  defp apply_action(socket, :new, _params) do
    page_title = gettext("New Notification template")

    socket
    |> assign(:page_title, page_title)
    |> assign(:notification_template, %NotificationTemplate{})
  end

  defp apply_action(socket, :index, _params) do
    page_title = gettext("Listing Notification templates")

    socket
    |> assign(:page_title, page_title)
    |> assign(:notification_template, nil)
  end

  @impl true
  def handle_info(
        {PrepairWeb.NotificationTemplateLive.FormComponent,
         {:saved, notification_template}},
        socket
      ) do
    {:noreply,
     stream_insert(socket, :notification_templates, notification_template)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    UserAuth.require_admin_and_do(socket, fn ->
      notification_template = Notifications.get_notification_template!(id)

      {:ok, _} =
        Notifications.delete_notification_template(notification_template)

      {:noreply,
       stream_delete(socket, :notification_templates, notification_template)}
    end)
  end
end
