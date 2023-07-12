defmodule Prepair.AdminEmail do
  @moduledoc """
  Admin notification emails.
  """

  import Swoosh.Email

  @doc """
  Builds an email to notify a new subscriber.
  """
  @spec new_subscriber(String.t()) :: Swoosh.Email.t()
  def new_subscriber(email) do
    admin_email()
    |> subject("New subscriber")
    |> text_body("New subscriber: #{email}")
  end

  @doc """
  Build an email to notify a Mailer Lite API error.
  """
  @spec mailerlite_error(any()) :: Swoosh.Email.t()
  def mailerlite_error(error) do
    admin_email()
    |> subject("Mailerlite API error")
    |> text_body(
      "An error has occured while trying to use the mailerlite API: #{inspect(error)}"
    )
  end

  @spec admin_email :: Swoosh.Email.t()
  defp admin_email do
    config = Application.fetch_env!(:prepair, :emails)

    new()
    |> to(Keyword.fetch!(config, :admin_contacts))
    |> from(Keyword.fetch!(config, :sender))
  end
end
