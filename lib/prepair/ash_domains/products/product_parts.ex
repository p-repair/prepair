defmodule Prepair.AshDomains.Products.ProductParts do
  use Ash.Resource,
    domain: Prepair.AshDomains.Products,
    data_layer: AshPostgres.DataLayer

  alias Prepair.AshDomains.Products.{Product, Part}

  postgres do
    table "product_parts"
    repo Prepair.Repo

    references do
      reference :product, on_delete: :delete
      reference :part, on_delete: :delete
    end

    custom_indexes do
      index :product_id, unique: false
      index :part_id, unique: false
    end
  end

  relationships do
    belongs_to :product, Product do
      source_attribute :product_id
      destination_attribute :id
      primary_key? true
      allow_nil? false
    end

    belongs_to :part, Part do
      source_attribute :part_id
      destination_attribute :id
      primary_key? true
      allow_nil? false
    end
  end
end
