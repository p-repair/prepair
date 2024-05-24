defmodule Prepair.AshDomains.Profiles.Ownership do
  use Ash.Resource,
    domain: Prepair.AshDomains.Profiles,
    extensions: [AshJsonApi.Resource],
    data_layer: AshPostgres.DataLayer

  alias Prepair.AshDomains.Products.Product
  alias Prepair.AshDomains.Profiles.Profile

  postgres do
    table "ownerships"
    repo Prepair.Repo

    references do
      reference :product, on_delete: :delete
      reference :profile, on_delete: :delete
    end

    custom_indexes do
      index :product_id, unique: false
      index :profile_id, unique: false
    end

    migration_types price_of_purchase: :integer,
                    warranty_duration_m: :integer
  end

  attributes do
    uuid_primary_key :id
    attribute :date_of_purchase, :date, allow_nil?: false
    attribute :price_of_purchase, :integer
    attribute :public, :boolean, allow_nil?: false, default: false
    attribute :warranty_duration_m, :integer
    create_timestamp :inserted_at, type: :utc_datetime
    update_timestamp :updated_at, type: :utc_datetime
  end

  relationships do
    belongs_to :product, Product do
      source_attribute :product_id
      destination_attribute :id
    end

    belongs_to :profile, Profile do
      source_attribute :profile_id
      destination_attribute :id
    end
  end
end
