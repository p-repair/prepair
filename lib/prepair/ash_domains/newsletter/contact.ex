defmodule Prepair.AshDomains.Newsletter.Contact do
  use Ash.Resource,
    domain: Prepair.AshDomains.Newsletter,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "contacts"
    repo Prepair.Repo

    migration_types email: :string,
                    lang: :string
  end

  attributes do
    uuid_primary_key :id

    attribute :email, :string do
      allow_nil? false
      constraints match: ~r/^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+.[a-zA-Z0-9-.]+$/
    end

    attribute :lang, :string
    attribute :mailerlite_id, :integer
    create_timestamp :inserted_at, type: :utc_datetime
    update_timestamp :updated_at, type: :utc_datetime
  end

  identities do
    identity :email, :email
  end
end
