defmodule PrepairWeb.UserRegistrationLive do
  alias Ecto.Changeset
  use PrepairWeb, :live_view

  alias Prepair.Accounts
  alias Prepair.Accounts.Registration

  import Phoenix.HTML.Form

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        <%= gettext "Register for an account" %>
        <:subtitle>
          <%= gettext "Already registered?" %>
          <.link navigate={~p"/users/log_in"} class="font-semibold text-brand hover:underline">
            <%= gettext "Sign in" %>
          </.link>
          <%= gettext "to your account now." %>
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="registration_form"
        phx-submit="save"
        phx-change="validate"
        phx-trigger-action={@trigger_submit}
        action={~p"/users/log_in?_action=registered"}
        method="post"
      >
        <.error :if={@check_errors}>
          <%= gettext "Oops, something went wrong! Please check the errors below." %>
        </.error>

        <.input
          field={@form[:username]}
          type="text"
          label={gettext "Username"}
          required
        />

        <.input
          field={@form[:email]}
          type="email"
          label={gettext "Email"}
          required
        />

        <.input
          field={@form[:password]}
          type="password"
          label={gettext "Password"}
          value={input_value(@form, :password)}
          required
        />

        <.input
          field={@form[:password_confirmation]}
          type="password"
          label={gettext "Password confirmation"}
          value={input_value(@form, :password_confirmation)}
          required
        />

        <.input
          field={@form[:people_in_household]}
          label={gettext "People in household"}
          type="select"
          options={[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]}
          required
        />

        <.input
          field={@form[:newsletter]}
          type="checkbox"
          label={gettext "I want to subscribe to the newsletter"}
        />

        <:actions>
          <.button phx-disable-with={gettext "Creating account..."} class="w-full"><%= gettext "Create an account" %></.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    changeset = %Registration{} |> Registration.changeset(%{})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"user" => registration_params}, socket) do
    case Accounts.register_user(registration_params) do
      {:ok, _user} ->
        changeset =
          %Registration{} |> Registration.changeset(registration_params)

        socket = assign(socket, changeset: changeset, trigger_submit: true)
        {:noreply, socket}

      {:error, %Changeset{} = changeset} ->
        {:noreply,
         socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => registration_params}, socket) do
    changeset = %Registration{} |> Registration.changeset(registration_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
