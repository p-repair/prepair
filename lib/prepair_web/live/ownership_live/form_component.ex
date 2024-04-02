defmodule PrepairWeb.OwnershipLive.FormComponent do
  use PrepairWeb, :live_component

  alias Prepair.Profiles
  alias Prepair.Products
  alias Prepair.Repo

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage ownership records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="ownership-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input
          field={@form[:category_uuid]}
          label="Category"
          type="select"
          prompt="Please select a category"
          options={category_opts(@changeset)}
        />
        <.input
          field={@form[:manufacturer_uuid]}
          label="Manufacturer"
          type="select"
          prompt="Please select a manufacturer"
          options={manufacturer_opts(@changeset)}
        />
        <.input
          field={@form[:product_uuid]}
          label="Product name"
          type="select"
          prompt="Please select a product (filter by category and manufacturer)"
          options={product_opts(@form.params, @changeset)}
        />
        <.input field={@form[:date_of_purchase]} type="date" label="Date of purchase" />
        <.input field={@form[:warranty_duration_m]} type="number" label="Warranty duration (in months)" />
        <.input field={@form[:price_of_purchase]} type="number" label="Price of purchase" />
        <.input field={@form[:public]} type="checkbox" label="Public" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Ownership</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{ownership: ownership} = assigns, socket) do
    changeset = Profiles.change_ownership(ownership)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(changeset: changeset)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"ownership" => ownership_params}, socket) do
    changeset =
      socket.assigns.ownership
      |> Profiles.change_ownership(ownership_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event("save", %{"ownership" => ownership_params}, socket) do
    save_ownership(socket, socket.assigns.action, ownership_params)
  end

  defp category_opts(changeset) do
    existing_uuids =
      changeset
      |> Ecto.Changeset.get_change(:categories, [])
      |> Enum.map(& &1.data.uuid)

    opts =
      for cat <- Products.list_categories(),
          do: [
            key: cat.name,
            value: cat.uuid,
            selected: cat.uuid in existing_uuids
          ]

    opts
  end

  defp manufacturer_opts(changeset) do
    existing_uuids =
      changeset
      |> Ecto.Changeset.get_change(:manufacturers, [])
      |> Enum.map(& &1.data.uuid)

    opts =
      for man <- Products.list_manufacturers(),
          do: [
            key: man.name,
            value: man.uuid,
            selected: man.uuid in existing_uuids
          ]

    opts
  end

  defp product_opts(params, changeset) do
    existing_uuids =
      changeset
      |> Ecto.Changeset.get_change(:products, [])
      |> Enum.map(& &1.data.uuid)

    with {:ok, category_uuid} <- Map.fetch(params, "category_uuid"),
         {:ok, manufacturer_uuid} <- Map.fetch(params, "manufacturer_uuid") do
      opts =
        for p <-
              Products.list_products(
                category_uuid: [category_uuid],
                manufacturer_uuid: [manufacturer_uuid]
              ),
            do: [key: p.name, value: p.uuid, selected: p.uuid in existing_uuids]

      opts
    else
      :error ->
        opts =
          for p <- Products.list_products(),
              do: [
                key: p.name,
                value: p.uuid,
                selected: p.uuid in existing_uuids
              ]

        opts

      _ ->
        raise("Unexpected behaviour.")
    end
  end

  defp save_ownership(socket, :edit, ownership_params) do
    case Profiles.update_ownership(socket.assigns.ownership, ownership_params) do
      {:ok, ownership} ->
        notify_parent({:saved, ownership |> Repo.preload([:product, :profile])})

        {:noreply,
         socket
         |> put_flash(:info, "Ownership updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_ownership(socket, :new, ownership_params) do
    case Profiles.create_ownership(
           socket.assigns.current_user.uuid,
           ownership_params
         ) do
      {:ok, ownership} ->
        notify_parent({:saved, ownership |> Repo.preload([:product, :profile])})

        {:noreply,
         socket
         |> put_flash(:info, "Ownership created successfully")
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
