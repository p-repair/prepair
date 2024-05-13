defmodule PrepairWeb.ContactController do
  use PrepairWeb, :controller

  alias Prepair.LegacyContexts.Newsletter
  alias Prepair.LegacyContexts.Newsletter.Contact

  def index(conn, _params) do
    contacts = Newsletter.list_contacts()
    render(conn, :index, contacts: contacts)
  end

  def new(conn, _params) do
    changeset = Newsletter.change_contact(%Contact{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"contact" => contact_params}) do
    case Newsletter.create_contact(contact_params) do
      {:ok, contact} ->
        conn
        |> put_flash(:info, dgettext("infos", "Contact created successfully."))
        |> redirect(to: ~p"/contacts/#{contact}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    contact = Newsletter.get_contact!(id)
    render(conn, :show, contact: contact)
  end

  def edit(conn, %{"id" => id}) do
    contact = Newsletter.get_contact!(id)
    changeset = Newsletter.change_contact(contact)
    render(conn, :edit, contact: contact, changeset: changeset)
  end

  def update(conn, %{"id" => id, "contact" => contact_params}) do
    contact = Newsletter.get_contact!(id)

    case Newsletter.update_contact(contact, contact_params) do
      {:ok, contact} ->
        conn
        |> put_flash(:info, dgettext("infos", "Contact updated successfully."))
        |> redirect(to: ~p"/contacts/#{contact}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, contact: contact, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    contact = Newsletter.get_contact!(id)
    {:ok, _contact} = Newsletter.delete_contact(contact)

    conn
    |> put_flash(:info, dgettext("infos", "Contact deleted successfully."))
    |> redirect(to: ~p"/contacts")
  end
end
