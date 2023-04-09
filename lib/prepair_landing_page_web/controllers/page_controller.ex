defmodule PrepairLandingPageWeb.PageController do
  use PrepairLandingPageWeb, :controller
  alias PrepairLandingPage.SubscribeData
  alias Ecto.Changeset

  def home(conn, _params) do
    conn
    |> render(
      :home,
      changeset: SubscribeData.changeset(%SubscribeData{}),
      layout: false
    )
  end

  def subscribe(conn, params) do
    changeset =
      SubscribeData.changeset(%SubscribeData{}, params["subscribe_data"])

    if(changeset.valid?) do
      email = Changeset.fetch_change!(changeset, :email)

      case Sendinblue.DefaultImpl.create_a_contact(%{
             "udpateEnabled" => true,
             "email" => email
           }) do
        {:error, _} ->
          conn
          |> put_flash(
            :error,
            "Nous sommes désolés du probleme…
            Il y a eu une erreur lors de l’inscription.
            Réessayez plus tard s’il vous plait !"
          )
          |> redirect(to: "/")
          |> render(conn, changeset: changeset)

        {:ok, _} ->
          conn
          |> put_flash(
            :info,
            "Merci !! Votre inscription a bien été prise en compte."
          )
          |> redirect(to: "/")
      end
    else
      conn
      |> put_flash(
        :error,
        "Essayez encore ! L’adresse email saisie n’est pas valide."
      )
      |> redirect(to: "/")
      |> render(conn, changeset: changeset)
    end
  end
end
