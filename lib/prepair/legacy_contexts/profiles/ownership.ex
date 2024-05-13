defmodule Prepair.LegacyContexts.Profiles.Ownership do
  use Ecto.Schema

  alias Prepair.LegacyContexts.Products.Product
  alias Prepair.LegacyContexts.Profiles.Profile

  import Ecto.Changeset

  @required_fields [
    :product_id,
    :product_id,
    :public,
    :date_of_purchase
  ]

  @fields @required_fields ++
            [
              :warranty_duration_m,
              :price_of_purchase
            ]

  @derive {Phoenix.Param, key: :id}
  @primary_key {:id, Ecto.UUID, autogenerate: false}
  schema "ownerships" do
    belongs_to :product, Product,
      foreign_key: :product_id,
      references: :id,
      type: Ecto.UUID

    belongs_to :profile, Profile,
      foreign_key: :profile_id,
      references: :id,
      type: Ecto.UUID

    field :public, :boolean, default: false
    field :date_of_purchase, :date
    field :warranty_duration_m, :integer
    field :price_of_purchase, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(ownership, attrs) do
    ownership
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
  end
end
