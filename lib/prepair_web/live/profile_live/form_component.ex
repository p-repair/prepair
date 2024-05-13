defmodule PrepairWeb.ProfileLive.FormComponent do
  use PrepairWeb, :live_component

  alias Prepair.LegacyContexts.Profiles

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>
          <%= gettext("Use this form to manage profile records in your database.") %>
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="profile-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:username]} type="text" label={gettext("Username")} />
        <.input
          field={@form[:people_in_household]}
          type="number"
          label={gettext("People in household")}
        />
        <.input
          field={@form[:newsletter]}
          type="checkbox"
          label={gettext("Newsletter")}
        />
        <:actions>
          <.button phx-disable-with={gettext("Saving...")}>
            <%= gettext("Save Profile") %>
          </.button>
          <.back navigate={~p"/profiles/#{@profile}"}>
            <%= gettext("Back to profile") %>
          </.back>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{profile: profile} = assigns, socket) do
    changeset = Profiles.change_profile(profile)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"profile" => profile_params}, socket) do
    changeset =
      socket.assigns.profile
      |> Profiles.change_profile(profile_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"profile" => profile_params}, socket) do
    save_profile(socket, socket.assigns.action, profile_params)
  end

  defp save_profile(socket, :edit, profile_params) do
    with {:ok, profile} <-
           Profiles.update_profile(
             socket.assigns.profile,
             profile_params
           ) do
      notify_parent({:saved, profile})

      {:noreply,
       socket
       |> put_flash(:info, dgettext("infos", "Profile updated successfully"))
       |> push_patch(to: socket.assigns.patch)}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_profile(socket, :new, profile_params) do
    case Profiles.create_profile(profile_params) do
      {:ok, profile} ->
        notify_parent({:saved, profile})

        {:noreply,
         socket
         |> put_flash(:info, dgettext("infos", "Profile created successfully"))
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
