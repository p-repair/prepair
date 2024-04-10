defmodule PrepairWeb.UserUpdateEmailLive do
  use PrepairWeb, :live_view

  alias Prepair.Accounts
  alias Prepair.Accounts.User

  import Phoenix.HTML.Form

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        <%= gettext "Update your email address" %>

        <:actions>
          <.link patch={~p"/"}>
            <.button><%= gettext "Go Back Home" %></.button>
          </.link>
        </:actions>
      </.header>


      <.simple_form
        for={@form}
        id="update_email_form"
        phx-submit="save"
        phx-change="validate"
      >
        <.error :if={@check_errors}>
          <%= gettext "Oops, something went wrong! Please check the errors below." %>
        </.error>

        <div class = "text-sm leading-7">
          <b>Current email</b><br />
          <%= @current_email %>
          </div>


        <.input
          field={@form[:current_password]}
          type="password"
          label={gettext "Password"}
          required
        />

        <.input
          field={@form[:email]}
          type="email"
          label={gettext "New email"}
          required
        />

        <.input
          field={@form[:email_confirmation]}
          type="email"
          label={gettext "New email confirmation"}
          value={input_value(@form, :email_confirmation)}
          required
        />

        <:actions>
          <.button phx-disable-with={gettext "Updating email..."} class="w-full"><%= gettext "Update email" %></.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    current_user = socket.assigns.current_user

    changeset = Accounts.change_user_email(%User{})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign(:current_email, current_user.email)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  # TODO: transform to a modal from the current profile page
  def handle_event("save", %{"user" => params}, socket) do
    current_user = socket.assigns.current_user

    case Accounts.update_user_email_basic(
           current_user,
           params["current_password"],
           params
         ) do
      {:ok, _user} ->
        socket =
          socket
          |> put_flash(:info, dgettext("infos", "Email updated successfully!"))
          |> push_navigate(to: ~p"/")

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        socket =
          socket
          |> assign_form(changeset)
          |> assign(check_errors: true)

        {:noreply, socket}
    end
  end

  def handle_event("validate", %{"user" => params}, socket) do
    current_user = socket.assigns.current_user
    changeset = Accounts.change_user_email(current_user, params)

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
