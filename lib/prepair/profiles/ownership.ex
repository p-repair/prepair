defmodule Prepair.Profiles.Ownership do
  use Ecto.Schema

  alias Prepair.Products.Product
  alias Prepair.Profiles.Profile

  import Ecto.Changeset

  @required_fields [
    :product_uuid,
    :product_uuid,
    :public,
    :date_of_purchase
  ]

  @fields @required_fields ++
            [
              :warranty_duration_m,
              :price_of_purchase
            ]

  @derive {Phoenix.Param, key: :uuid}
  @primary_key {:uuid, Ecto.UUID, autogenerate: false}
  schema "ownerships" do
    belongs_to :product, Product,
      foreign_key: :product_uuid,
      references: :uuid,
      type: Ecto.UUID

    belongs_to :profile, Profile,
      foreign_key: :profile_uuid,
      references: :uuid,
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
