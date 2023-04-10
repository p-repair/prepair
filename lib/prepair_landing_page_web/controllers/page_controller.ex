defmodule PrepairLandingPageWeb.PageController do
  use PrepairLandingPageWeb, :controller

  alias PrepairLandingPage.Newsletter
  alias PrepairLandingPage.Newsletter.Contact
  alias Ecto.Changeset

  def home(conn, _params) do
    conn
    |> render(
      :home,
      changeset: Newsletter.change_contact(%Contact{}),
      layout: false
    )
  end

  def subscribe(conn, params) do
    case Newsletter.create_contact(params["contact"]) do
      {:ok, _} ->
        conn
        |> put_flash(
          :info,
          "Merci !! Votre inscription a bien été prise en compte."
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
            "Merci !! Votre inscription a bien été prise en compte."
          )
          |> redirect(to: "/")
        else
          conn
          |> put_flash(
            :error,
            "Essayez encore ! L’adresse email saisie n’est pas valide."
          )
          |> redirect(to: "/")
        end

      {:error, _} ->
        conn
        |> put_flash(
          :error,
          "Nous sommes désolés du probleme…
            Il y a eu une erreur lors de l’inscription.
            Réessayez plus tard s’il vous plait !"
        )
        |> redirect(to: "/")
    end
  end
end
