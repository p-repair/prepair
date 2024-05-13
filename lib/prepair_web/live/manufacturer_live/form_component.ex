defmodule PrepairWeb.ManufacturerLive.FormComponent do
  use PrepairWeb, :live_component

  alias Prepair.LegacyContexts.Products

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>
          <%= gettext(
            "Use this form to manage manufacturer records in your database."
          ) %>
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="manufacturer-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label={gettext("Name")} />
        <.input
          field={@form[:description]}
          type="text"
          label={gettext("Description")}
        />
        <.input field={@form[:image]} type="text" label={gettext("Image")} />
        <:actions>
          <.button phx-disable-with={gettext("Saving...")}>
            <%= gettext("Save Manufacturer") %>
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{manufacturer: manufacturer} = assigns, socket) do
    changeset = Products.change_manufacturer(manufacturer)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"manufacturer" => manufacturer_params}, socket) do
    changeset =
      socket.assigns.manufacturer
      |> Products.change_manufacturer(manufacturer_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"manufacturer" => manufacturer_params}, socket) do
    save_manufacturer(socket, socket.assigns.action, manufacturer_params)
  end

  defp save_manufacturer(socket, :edit, manufacturer_params) do
    case Products.update_manufacturer(
           socket.assigns.manufacturer,
           manufacturer_params
         ) do
      {:ok, manufacturer} ->
        notify_parent({:saved, manufacturer})

        {:noreply,
         socket
         |> put_flash(
           :info,
           dgettext("infos", "Manufacturer updated successfully")
         )
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_manufacturer(socket, :new, manufacturer_params) do
    case Products.create_manufacturer(manufacturer_params) do
      {:ok, manufacturer} ->
        notify_parent({:saved, manufacturer})

        {:noreply,
         socket
         |> put_flash(
           :info,
           dgettext("infos", "Manufacturer created successfully")
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
end
