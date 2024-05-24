defmodule Prepair.AshDomains.Accounts.Registration do
  use Ash.Resource,
    data_layer: :embedded

  # alias Prepair.AshDomains.Accounts.{User, Registration}
  # alias Prepair.AshDomains.Profiles.Profile

  import Prepair.AshDomains.ValidationMacros
  import PrepairWeb.Gettext

  attributes do
    uuid_primary_key :id
    attribute :username, :string, allow_nil?: false
    attribute :email, :string, allow_nil?: false
    attribute :password, :string, allow_nil?: false
    attribute :password_confirmation, :string, allow_nil?: false
    attribute :people_in_household, :integer, allow_nil?: false
    attribute :newsletter, :boolean, allow_nil?: false

    attribute :role, :atom do
      constraints one_of: [:user, :admin]
    end
  end

  actions do
    default_accept [
      :username,
      :email,
      :people_in_household,
      :newsletter,
      :password,
      :password_confirmation,
      :role
    ]

    create :register do
      # accept [
      #   :username,
      #   :email,
      #   :people_in_household,
      #   :newsletter,
      #   :password,
      #   :password_confirmation,
      #   :role
      # ]

      # argument :password, :string, allow_nil?: false
      # argument :password_confirmation, :string, allow_nil?: false
    end
  end

  validations do
    validate_email()
    validate_password()

    validate confirm(:password, :password_confirmation) do
      on [:create, :update]
      # where [action_is(:create)]
      message dgettext("errors", "does not match")
    end
  end
end
