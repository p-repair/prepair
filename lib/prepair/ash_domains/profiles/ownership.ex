defmodule Prepair.AshDomains.Profiles.Ownership do
  use Ash.Resource,
    domain: Prepair.AshDomains.Profiles,
    extensions: [AshJsonApi.Resource],
    data_layer: AshPostgres.DataLayer

  alias Prepair.AshDomains.Products.Product
  alias Prepair.AshDomains.Profiles.Profile

  require Ash.Query

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

  code_interface do
    define :list, action: :read
    define :list_by_profile
    define :list_by_product
    define :get, action: :read, get_by: :id
    define :create, args: [:profile_id]
    define :update
    define :delete, action: :destroy
  end

  actions do
    default_accept [
      :date_of_purchase,
      :price_of_purchase,
      :product_id,
      :public,
      :warranty_duration_m
    ]

    defaults [:read, :update, :destroy]

    read :list_by_profile do
      argument :profile_id, :uuid
      argument :include_private, :boolean, default: false

      filter expr(
               if ^arg(:include_private) == true do
                 profile_id == ^arg(:profile_id)
               else
                 profile_id == ^arg(:profile_id) and public == true
               end
             )
    end

    read :list_by_product do
      argument :product_id, :uuid
      argument :include_private, :boolean, default: false

      filter expr(
               if ^arg(:include_private) == true do
                 product_id == ^arg(:product_id)
               else
                 product_id == ^arg(:product_id) and public == true
               end
             )
    end

    create :create do
      primary? true
      argument :profile_id, :uuid
      change set_attribute(:profile_id, arg(:profile_id))
    end
  end

  # -------------------------------------------------------------------------- #
  #              Additional functions not implemented through Ash              #
  # -------------------------------------------------------------------------- #

  import Ecto.Query
  alias Prepair.{Repo, AshDomains.Profiles.Ownership}

  def count_by_product(product_id) do
    query =
      from o in Ownership,
        where: o.product_id == ^product_id,
        select: count()

    Repo.all(query)
    |> Enum.fetch!(0)
  end
end
