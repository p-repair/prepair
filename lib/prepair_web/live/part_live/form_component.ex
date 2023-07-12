defmodule PrepairWeb.PartLive.FormComponent do
  use PrepairWeb, :live_component

  alias Prepair.Products

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage part records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="part-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:reference]} type="text" label="Reference" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:image]} type="text" label="Image" />
        <.input field={@form[:average_lifetime_m]} type="number" label="Average lifetime m" />
        <.input field={@form[:country_of_origin]} type="text" label="Country of origin" />
        <.input field={@form[:main_material]} type="text" label="Main material" />
        <.input field={@form[:start_of_production]} type="date" label="Start of production" />
        <.input field={@form[:end_of_production]} type="date" label="End of production" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Part</.button>
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

  defp save_part(socket, :edit, part_params) do
    case Products.update_part(socket.assigns.part, part_params) do
      {:ok, part} ->
        notify_parent({:saved, part})

        {:noreply,
         socket
         |> put_flash(:info, "Part updated successfully")
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
         |> put_flash(:info, "Part created successfully")
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
