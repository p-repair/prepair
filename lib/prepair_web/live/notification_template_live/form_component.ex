defmodule PrepairWeb.NotificationTemplateLive.FormComponent do
  use PrepairWeb, :live_component

  alias Prepair.Notifications
  alias Prepair.Products

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>
          <%= gettext(
            "Use this form to manage notification_template records in your database."
          ) %>
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="notification_template-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label={gettext("Name")} />
        <.input field={@form[:title]} type="text" label={gettext("Title")} />
        <.input field={@form[:content]} type="text" label={gettext("Content")} />
        <.input
          field={@form[:description]}
          type="text"
          label={gettext("Description")}
        />
        <.input
          field={@form[:category_ids]}
          label={gettext("Categories")}
          type="select"
          multiple={true}
          options={categories_opts(@form)}
        />
        <.input
          field={@form[:product_ids]}
          label={gettext("Products")}
          type="select"
          multiple={true}
          options={products_opts(@form)}
        />
        <.input
          field={@form[:part_ids]}
          label={gettext("Parts")}
          type="select"
          multiple={true}
          options={parts_opts(@form)}
        />
        <.input field={@form[:condition]} type="text" label={gettext("Condition")} />
        <.input
          field={@form[:need_action]}
          type="checkbox"
          label={gettext("User action needed")}
        />
        <.input field={@form[:draft]} type="checkbox" label={gettext("Draft")} />
        <:actions>
          <.button phx-disable-with={gettext("Saving...")}>
            <%= gettext("Save Notification template") %>
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{notification_template: notification_template} = assigns, socket) do
    changeset =
      Notifications.change_notification_template(notification_template)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event(
        "validate",
        %{"notification_template" => notification_template_params},
        socket
      ) do
    params = notification_template_params |> normalise_params()

    changeset =
      socket.assigns.notification_template
      |> Notifications.change_notification_template(params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event(
        "save",
        %{"notification_template" => notification_template_params},
        socket
      ) do
    save_notification_template(
      socket,
      socket.assigns.action,
      notification_template_params
    )
  end

  defp categories_opts(%Phoenix.HTML.Form{} = form) do
    existing_ids =
      form.source
      |> Ecto.Changeset.get_change(:categories, [])
      |> Enum.map(& &1.data.id)

    opts =
      for cat <- Products.list_categories(),
          do: [key: cat.name, value: cat.id, selected: cat.id in existing_ids]

    opts
  end

  defp products_opts(%Phoenix.HTML.Form{} = form) do
    existing_ids =
      form.source
      |> Ecto.Changeset.get_change(:products, [])
      |> Enum.map(& &1.data.id)

    opts =
      for prod <- Products.list_products(),
          do: [
            key: prod.name,
            value: prod.id,
            selected: prod.id in existing_ids
          ]

    opts
  end

  defp parts_opts(%Phoenix.HTML.Form{} = form) do
    existing_ids =
      form.source
      |> Ecto.Changeset.get_change(:parts, [])
      |> Enum.map(& &1.data.id)

    opts =
      for part <- Products.list_parts(),
          do: [
            key: part.name,
            value: part.id,
            selected: part.id in existing_ids
          ]

    opts
  end

  defp save_notification_template(socket, :edit, notification_template_params) do
    params = notification_template_params |> normalise_params()

    case Notifications.update_notification_template(
           socket.assigns.notification_template,
           params
         ) do
      {:ok, notification_template} ->
        notify_parent({:saved, notification_template})

        {:noreply,
         socket
         |> put_flash(
           :info,
           dgettext("infos", "Notification template updated successfully")
         )
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_notification_template(socket, :new, notification_template_params) do
    params = notification_template_params |> normalise_params()

    case Notifications.create_notification_template(params) do
      {:ok, notification_template} ->
        notify_parent({:saved, notification_template})

        {:noreply,
         socket
         |> put_flash(
           :info,
           dgettext("infos", "Notification template created successfully")
         )
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  # TODO: Do not normalise params (see #68).
  # Helper function to normalise parameters before to pass them to context
  # functions.
  defp normalise_params(params) do
    update_fields = [:category_ids, :product_ids, :part_ids]

    keys =
      Map.keys(params)
      |> Enum.map(&String.to_existing_atom/1)

    values =
      Map.values(params)

    map =
      Enum.zip(keys, values)
      |> Enum.into(%{})

    normalise_params =
      Enum.reduce(update_fields, map, fn x, acc ->
        Map.replace_lazy(acc, x, fn v ->
          Enum.map(v, fn y -> String.to_integer(y) end)
        end)
      end)

    normalise_params
  end
end
