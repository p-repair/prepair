defmodule Prepair.Products.Product do
  use Ecto.Schema
  import Ecto.Changeset

  @fields [
    :category_id,
    :manufacturer_id,
    :part_ids,
    :name,
    :reference,
    :description,
    :image,
    :average_lifetime_m,
    :country_of_origin,
    :start_of_production,
    :end_of_production
  ]

  @required_fields [
    :category_id,
    :manufacturer_id,
    :name,
    :reference
  ]

  schema "products" do
    field :average_lifetime_m, :integer
    field :country_of_origin, :string
    field :description, :string
    field :end_of_production, :date
    field :image, :string
    field :name, :string
    field :reference, :string
    field :start_of_production, :date
    field :manufacturer_id, :id
    field :category_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:reference)
  end
end
