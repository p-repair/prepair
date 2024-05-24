defmodule Prepair.LegacyContexts.NewsletterFixtures do
  @moduledoc """
  This module defines test helpers for creating
  fake contacts, derictly on the repo, to don’t pollute our MailerLite API.
  """

  alias Prepair.AshDomains.Newsletter.Contact

  def unique_email_adress,
    do: "test_#{System.unique_integer([:positive])}@test.org"

  # This way, the fixture don’t create a contact on MailerLite.
  def contact_fixture() do
    Ash.Seed.seed!(%Contact{email: unique_email_adress()})
  end
end
