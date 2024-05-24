defmodule Prepair.AshDomains.Profiles.Profile do
  use Ash.Resource,
    domain: Prepair.AshDomains.Profiles,
    data_layer: AshPostgres.DataLayer

  alias Prepair.AshDomains.Accounts.User
  alias Prepair.AshDomains.Profiles.Ownership

  postgres do
    table "profiles"
    repo Prepair.Repo

    references do
      reference :user, on_delete: :delete
    end

    migration_types username: :string,
                    people_in_household: :integer
  end

  attributes do
    attribute :id, :uuid, primary_key?: true, allow_nil?: false
    attribute :username, :string, allow_nil?: false
    attribute :newsletter, :boolean, allow_nil?: false
    attribute :people_in_household, :integer, allow_nil?: false
    create_timestamp :inserted_at, type: :utc_datetime
    update_timestamp :updated_at, type: :utc_datetime
  end

  relationships do
    # Should be OK
    belongs_to :user, User do
      define_attribute? false
      source_attribute :id
      destination_attribute :id
    end

    has_many :ownerships, Ownership do
      source_attribute :id
      destination_attribute :profile_id
    end
  end

  identities do
    identity :username, [:username]
  end
end
