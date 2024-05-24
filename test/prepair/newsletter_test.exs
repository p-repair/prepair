defmodule Prepair.LegacyContexts.NewsletterTest do
  use Prepair.DataCase

  import Prepair.LegacyContexts.NewsletterFixtures

  # NOTE: Wo do not test the MailerLite API to don’t pollute our MailerLite
  # account with tests. MailerLite API tests currently occurs "by hand".

  describe "contacts" do
    alias Prepair.AshDomains.Newsletter.Contact

    @tag :contact_resource
    test "Contact.list/0 returns all contacts" do
      contact = contact_fixture()
      assert {:ok, [c]} = Contact.list()
      assert c.id == contact.id
    end

    @tag :contact_resource
    test "Contact.get/1 returns the contact with given id" do
      contact = contact_fixture()
      assert {:ok, c} = Contact.get(contact.id)
      assert c.id == contact.id
    end

    @tag :contact_resource
    test "Contact.update/2 with valid data updates a contact" do
      contact = contact_fixture()

      assert {:ok, %Contact{}} =
               Contact.update(contact, %{email: "updated_email@test.org"})

      contact = Contact.get!(contact.id)
      assert contact.email == "updated_email@test.org"
    end

    # NOTE: This test doesn’t work since the MailerLite API key is not
    # parameterered in test environment.
    # @tag :contact_resource
    # test "Contact.create/2 with valid data creates a contact with a MailerLite
    # id" do
    #   assert {:ok, %Contact{} = contact} =
    #            Contact.create(%{email: unique_email_adress()})

    #   assert is_integer(contact.mailerlite_id)
    # end

    @tag :contact_resource
    test "Contact.create/2 with invalid data renders error and do not create" do
      assert {:error, %Ash.Error.Invalid{}} =
               Contact.create(%{email: "invalid"})

      assert {:ok, []} = Contact.list()
    end

    @tag :contact_resource
    test "Contact.update/2 with invalid data renders error and do not update" do
      contact = contact_fixture()
      email = contact.email

      assert {:error, %Ash.Error.Invalid{}} =
               Contact.update(contact, %{email: "invalid"})

      contact = Contact.get!(contact.id)

      assert contact.email == email
    end

    @tag :contact_resource
    test "Contact.delete/1 deletes the contact" do
      contact = contact_fixture()

      assert :ok == Contact.delete(contact)

      assert_raise Ash.Error.Query.NotFound, fn -> Contact.get!(contact.id) end
    end
  end
end
