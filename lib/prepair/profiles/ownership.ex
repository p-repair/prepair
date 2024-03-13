defmodule Prepair.Profiles.Ownership do
  use Ecto.Schema

  alias Prepair.Products.Product
  alias Prepair.Profiles.Profile

  import Ecto.Changeset

  @required_fields [
    :product_id,
    :public,
    :date_of_purchase
  ]

  @fields @required_fields ++
            [
              :warranty_duration_m,
              :price_of_purchase
            ]

  @primary_key {:id, :id, autogenerate: true}
  schema "ownerships" do
    belongs_to :product, Product
    belongs_to :profile, Profile

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
