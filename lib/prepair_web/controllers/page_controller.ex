defmodule PrepairWeb.PageController do
  use PrepairWeb, :controller

  alias Prepair.LegacyContexts.Newsletter
  alias Prepair.LegacyContexts.Newsletter.Contact
  alias Ecto.Changeset

  def home(conn, _params) do
    conn
    |> render(
      :home,
      changeset: Newsletter.change_contact(%Contact{})
    )
  end

  def my_data(conn, _params) do
    conn
    |> render(:"my-data")
  end

  def delete_my_data(conn, _params) do
    conn
    |> render(:"delete-my-data")
  end

  def subscribe(conn, params) do
    case Newsletter.create_contact(params["contact"]) do
      {:ok, _} ->
        conn
        |> put_flash(
          :info,
          dgettext(
            "infos",
            "Thank you!! Your registration has been taken into account."
          )
        )
        |> redirect(to: "/")

      {:error, %Changeset{} = changeset} ->
        if Enum.member?(
             changeset.errors,
             {:email,
              {"has already been taken",
               [constraint: :unique, constraint_name: "contacts_email_index"]}}
           ) do
          conn
          |> put_flash(
            :info,
            dgettext(
              "infos",
              "Thank you!! Your registration has been taken into account."
            )
          )
          |> redirect(to: "/")
        else
          conn
          |> put_flash(
            :error,
            dgettext(
              "errors",
              "Try again! The email address entered is not valid."
            )
          )
          |> redirect(to: "/")
        end

      {:error, _} ->
        conn
        |> put_flash(
          :error,
          dgettext(
            "errors",
            "Sorry for the issue…
            There was an error when registering.
            Please try again later!"
          )
        )
        |> redirect(to: "/")
    end
  end
end
