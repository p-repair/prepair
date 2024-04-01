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
          field={@form[:category_id]}
          label="Category"
          type="select"
          prompt="Please select a category"
          options={category_opts(@changeset)}
        />
        <.input
          field={@form[:manufacturer_id]}
          label="Manufacturer"
          type="select"
          prompt="Please select a manufacturer"
          options={manufacturer_opts(@changeset)}
        />
        <.input
          field={@form[:product_id]}
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
    existing_ids =
      changeset
      |> Ecto.Changeset.get_change(:categories, [])
      |> Enum.map(& &1.data.id)

    opts =
      for cat <- Products.list_categories(),
          do: [key: cat.name, value: cat.id, selected: cat.id in existing_ids]

    opts
  end

  defp manufacturer_opts(changeset) do
    existing_ids =
      changeset
      |> Ecto.Changeset.get_change(:manufacturers, [])
      |> Enum.map(& &1.data.id)

    opts =
      for man <- Products.list_manufacturers(),
          do: [key: man.name, value: man.id, selected: man.id in existing_ids]

    opts
  end

  defp product_opts(params, changeset) do
    existing_ids =
      changeset
      |> Ecto.Changeset.get_change(:products, [])
      |> Enum.map(& &1.data.id)

    with {:ok, category_id_string} <- Map.fetch(params, "category_id"),
         {:ok, manufacturer_id_string} <- Map.fetch(params, "manufacturer_id") do
      category_id =
        if category_id_string == "",
          do: "",
          else: String.to_integer(category_id_string)

      manufacturer_id =
        if manufacturer_id_string == "",
          do: "",
          else: String.to_integer(manufacturer_id_string)

      opts =
        for p <-
              Products.list_products(
                category_id: [category_id],
                manufacturer_id: [manufacturer_id]
              ),
            do: [key: p.name, value: p.id, selected: p.id in existing_ids]

      opts
    else
      :error ->
        opts =
          for p <- Products.list_products(),
              do: [key: p.name, value: p.id, selected: p.id in existing_ids]

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
           socket.assigns.current_user.id,
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
