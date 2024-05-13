defmodule PrepairWeb.UserUpdatePasswordLive do
  use PrepairWeb, :live_view

  alias Prepair.LegacyContexts.Accounts

  import Phoenix.HTML.Form

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        <%= gettext("Update your password") %>

        <:actions>
          <.link patch={~p"/"}>
            <.button><%= gettext("Go Back Home") %></.button>
          </.link>
        </:actions>
      </.header>

      <.simple_form
        for={@form}
        id="update_password_form"
        phx-submit="save"
        phx-change="validate"
        action={~p"/users/log_in?_action=password_updated"}
        method="post"
        phx-trigger-action={@trigger_submit}
      >
        <.error :if={@check_errors}>
          <%= gettext("Oops, something went wrong! Please check the errors below.") %>
        </.error>

        <.input
          field={@form[:email]}
          type="hidden"
          id="hidden_user_email"
          value={@current_email}
        />

        <.input
          field={@form[:current_password]}
          type="password"
          label={gettext("Current password")}
          required
        />

        <.input
          field={@form[:password]}
          type="password"
          label={gettext("New password")}
          value={input_value(@form, :password)}
          required
        />

        <.input
          field={@form[:password_confirmation]}
          type="password"
          label={gettext("New password confirmation")}
          value={input_value(@form, :password_confirmation)}
          required
        />

        <:actions>
          <.button phx-disable-with={gettext("Updating password...")} class="w-full">
            <%= gettext("Update password") %>
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    current_user = socket.assigns.current_user

    changeset = Accounts.change_user_password(current_user)

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign(:current_email, current_user.email)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"user" => params}, socket) do
    current_user = socket.assigns.current_user

    case Accounts.update_user_password(
           current_user,
           params["current_password"],
           params
         ) do
      {:ok, user} ->
        socket =
          socket
          |> assign_form(Accounts.change_user_password(user, params))
          |> assign(trigger_submit: true)

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        socket =
          socket
          |> assign_form(changeset)
          |> assign(check_errors: true)

        {:noreply, socket}
    end
  end

  # TODO: transform to a modal from the current profile page
  def handle_event("validate", %{"user" => params}, socket) do
    current_user = socket.assigns.current_user
    changeset = Accounts.change_user_password(current_user, params)

    socket =
      socket
      |> assign_form(Map.put(changeset, :action, :validate))

    {:noreply, socket}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
