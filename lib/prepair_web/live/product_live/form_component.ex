defmodule PrepairWeb.ProductLive.FormComponent do
  use PrepairWeb, :live_component

  alias Prepair.Products

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage product records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="product-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:category_id]} type="select" options={category_opts(@changeset)} label="Category" />
        <.input field={@form[:manufacturer_id]} type="select" options={manufacturer_opts(@changeset)} label="Manufacturer" />
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:reference]} type="text" label="Reference" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:image]} type="text" label="Image" />
        <.input field={@form[:average_lifetime_m]} type="number" label="Average lifetime m" />
        <.input field={@form[:country_of_origin]} type="text" label="Country of origin" />
        <.input field={@form[:start_of_production]} type="date" label="Start of production" />
        <.input field={@form[:end_of_production]} type="date" label="End of production" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Product</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{product: product} = assigns, socket) do
    changeset = Products.change_product(product)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"product" => product_params}, socket) do
    changeset =
      socket.assigns.product
      |> Products.change_product(product_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"product" => product_params}, socket) do
    save_product(socket, socket.assigns.action, product_params)
  end

  defp category_opts(changeset) do
    existing_ids =
      changeset
      |> Ecto.Changeset.get_change(:categories, [])
      |> Enum.map(& &1.data.id)

    for cat <- Prepair.Products.list_categories(),
        do: [key: cat.name, value: cat.id, selected: cat.id in existing_ids]
  end

  defp manufacturer_opts(changeset) do
    existing_ids =
      changeset
      |> Ecto.Changeset.get_change(:manufacturers, [])
      |> Enum.map(& &1.data.id)

    for man <- Prepair.Products.list_manufacturers(),
        do: [key: man.name, value: man.id, selected: man.id in existing_ids]
  end

  defp save_product(socket, :edit, product_params) do
    case Products.update_product(socket.assigns.product, product_params) do
      {:ok, product} ->
        notify_parent({:saved, product})

        {:noreply,
         socket
         |> put_flash(:info, "Product updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_product(socket, :new, product_params) do
    case Products.create_product(product_params) do
      {:ok, product} ->
        notify_parent({:saved, product})

        {:noreply,
         socket
         |> put_flash(:info, "Product created successfully")
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
