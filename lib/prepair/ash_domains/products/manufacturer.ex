defmodule Prepair.AshDomains.Products.Manufacturer do
  use Ash.Resource,
    domain: Prepair.AshDomains.Products,
    data_layer: AshPostgres.DataLayer

  alias Prepair.AshDomains.Products.{Product, Part}

  postgres do
    table "manufacturers"
    repo Prepair.Repo

    migration_types description: :string,
                    image: :string,
                    name: :string
  end

  attributes do
    uuid_primary_key :id
    attribute :description, :string
    attribute :image, :string
    attribute :name, :string, allow_nil?: false
    create_timestamp :inserted_at, type: :utc_datetime
    update_timestamp :updated_at, type: :utc_datetime
  end

  relationships do
    has_many :products, Product do
      source_attribute :id
      destination_attribute :manufacturer_id
    end

    has_many :parts, Part do
      source_attribute :id
      destination_attribute :manufacturer_id
    end
  end

  identities do
    identity :name, [:name]
  end

  code_interface do
    define :list, action: :read
    define :get, action: :read, get_by: :id
    define :create
    define :update
    define :delete, action: :destroy
  end

  actions do
    default_accept [:description, :image, :name]
    defaults [:create, :read, :update, :destroy]
  end
end
