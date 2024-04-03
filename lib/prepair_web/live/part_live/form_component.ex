defmodule PrepairWeb.PartLive.FormComponent do
  use PrepairWeb, :live_component

  alias Prepair.Products

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle><%= gettext "Use this form to manage part records in your database." %></:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="part-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:category_uuid]}
          type="select"
          options={category_opts(@changeset)}
          label={gettext "Category"} />
        <.input field={@form[:manufacturer_uuid]}
          type="select"
          options={manufacturer_opts(@changeset)}
          label={gettext "Manufacturer"} />
        <.input field={@form[:product_uuids]}
          type="select"
          options={products_opts((@changeset))}
          multiple={true}
          label={gettext "Compatible products"} />
        <.input field={@form[:name]} type="text" label={gettext "Name"} />
        <.input field={@form[:reference]} type="text" label={gettext "Reference"} />
        <.input field={@form[:description]} type="text" label={gettext "Description"} />
        <.input field={@form[:image]} type="text" label={gettext "Image"} />
        <.input field={@form[:average_lifetime_m]} type="number" label={gettext "Average lifetime m"} />
        <.input field={@form[:country_of_origin]} type="text" label={gettext "Country of origin"} />
        <.input field={@form[:main_material]} type="text" label={gettext "Main material"} />
        <.input field={@form[:start_of_production]} type="date" label={gettext "Start of production"} />
        <.input field={@form[:end_of_production]} type="date" label={gettext "End of production"} />
        <:actions>
          <.button phx-disable-with={gettext "Saving..."}><%= gettext "Save Part" %></.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{part: part} = assigns, socket) do
    changeset = Products.change_part(part)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"part" => part_params}, socket) do
    changeset =
      socket.assigns.part
      |> Products.change_part(part_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"part" => part_params}, socket) do
    save_part(socket, socket.assigns.action, part_params)
  end

  defp category_opts(changeset) do
    existing_uuids =
      changeset
      |> Ecto.Changeset.get_change(:categories, [])
      |> Enum.map(& &1.data.uuid)

    for cat <- Prepair.Products.list_categories(),
        do: [
          key: cat.name,
          value: cat.uuid,
          selected: cat.uuid in existing_uuids
        ]
  end

  defp manufacturer_opts(changeset) do
    existing_uuids =
      changeset
      |> Ecto.Changeset.get_change(:manufacturers, [])
      |> Enum.map(& &1.data.uuid)

    for man <- Prepair.Products.list_manufacturers(),
        do: [
          key: man.name,
          value: man.uuid,
          selected: man.uuid in existing_uuids
        ]
  end

  defp products_opts(changeset) do
    existing_uuids =
      changeset
      |> Ecto.Changeset.get_change(:products, [])
      |> Enum.map(& &1.data.uuid)

    for prod <- Prepair.Products.list_products(),
        do: [
          key: prod.name,
          value: prod.uuid,
          selected: prod.uuid in existing_uuids
        ]
  end

  defp save_part(socket, :edit, part_params) do
    case Products.update_part(socket.assigns.part, part_params) do
      {:ok, part} ->
        notify_parent({:saved, part})

        {:noreply,
         socket
         |> put_flash(:info, dgettext("infos", "Part updated successfully"))
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_part(socket, :new, part_params) do
    case Products.create_part(part_params) do
      {:ok, part} ->
        notify_parent({:saved, part})

        {:noreply,
         socket
         |> put_flash(:info, dgettext("infos", "Part created successfully"))
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
