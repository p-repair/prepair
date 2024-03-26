defmodule Prepair.Newsletter do
  @moduledoc """
  The Newsletter context.
  """

  import Ecto.Query, warn: false

  alias Prepair.AdminEmail
  alias Prepair.Mailer
  alias Prepair.Repo

  alias Prepair.Newsletter.Contact

  @mailerlite_group 85_000_079_548_614_620

  @doc """
  Returns the list of contacts.

  ## Examples

      iex> list_contacts()
      [%Contact{}, ...]

  """
  def list_contacts() do
    Repo.all(Contact)
  end

  @doc """
  Gets a single contact.

  Raises `Ecto.NoResultsError` if the Contact does not exist.

  ## Examples

      iex> get_contact!("d080e457-b29f-4b55-8cdf-8c0cf462e739")
      %Contact{}

      iex> get_contact!("0f3b9817-6433-409c-823d-7d1f1083430c")
      ** (Ecto.NoResultsError)

  """
  def get_contact!(uuid), do: Repo.get!(Contact, uuid)

  @doc """
  Creates a contact.

  ## Examples

      iex> create_contact(%{field: value})
      {:ok, %Contact{}}

      iex> create_contact(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_contact(attrs \\ %{}) do
    %Contact{}
    |> Contact.changeset(attrs)
    |> Repo.insert(returning: [:uuid])
    |> case do
      {:ok, %Contact{} = contact} ->
        _ = notify_subscription(contact)
        add_to_mailerlite(contact)

      error ->
        error
    end
  end

  defp notify_subscription(%Contact{} = contact) do
    Task.Supervisor.start_child(Prepair.AsyncEmailSupervisor, fn ->
      contact.email
      |> AdminEmail.new_subscriber()
      |> Mailer.deliver()
    end)
  end

  defp add_to_mailerlite(%Contact{} = contact) do
    @mailerlite_group
    |> MailerLite.Groups.add_subscriber(%{
      "autoresponders" => false,
      "email" => contact.email
    })
    |> case do
      {:ok, subscriber} ->
        update_contact(contact, %{mailerlite_id: subscriber["id"]})

      error ->
        :logger.error(
          "Unable to add the contact on MailerLite: #{inspect(error)}"
        )

        _ = notify_mailerlite_error(error)

        {:ok, contact}
    end
  end

  defp notify_mailerlite_error(error) do
    Task.Supervisor.start_child(Prepair.AsyncEmailSupervisor, fn ->
      error
      |> AdminEmail.mailerlite_error()
      |> Mailer.deliver()
    end)
  end

  @doc """
  Updates a contact.

  ## Examples

      iex> update_contact(contact, %{field: new_value})
      {:ok, %Contact{}}

      iex> update_contact(contact, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_contact(%Contact{} = contact, attrs) do
    contact
    |> Contact.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a contact.

  ## Examples

      iex> delete_contact(contact)
      {:ok, %Contact{}}

      iex> delete_contact(contact)
      {:error, %Ecto.Changeset{}}

  """
  def delete_contact(%Contact{} = contact) do
    Repo.delete(contact)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking contact changes.

  ## Examples

      iex> change_contact(contact)
      %Ecto.Changeset{data: %Contact{}}

  """
  def change_contact(%Contact{} = contact, attrs \\ %{}) do
    Contact.changeset(contact, attrs)
  end
end
