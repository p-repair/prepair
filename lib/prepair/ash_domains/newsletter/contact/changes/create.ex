defmodule Prepair.AshDomains.Newsletter.Contact.Create do
  use Ash.Resource.Change

  alias Prepair.AshDomains.Newsletter.Contact

  def change(changeset, _opts, _context) do
    Ash.Changeset.after_transaction(changeset, fn
      _changeset, {:ok, %Contact{} = contact} ->
        IO.inspect(changeset, label: "After transaction success")
        _ = notify_subscription(contact)
        add_to_mailerlite(contact)

      _changeset, {:error, error} ->
        {:error, error}
    end)
  end

  # -------------------------------------------------------------------------- #
  #                              Helper functions                              #
  # -------------------------------------------------------------------------- #

  alias Prepair.AdminEmail
  alias Prepair.Mailer

  @mailerlite_group 85_000_079_548_614_620

  defp notify_subscription(contact) do
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
        Contact.update(contact, %{mailerlite_id: subscriber["id"]})

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
end
