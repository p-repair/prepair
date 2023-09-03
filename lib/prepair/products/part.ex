defmodule Prepair.Products.Part do
  use Ecto.Schema
  import Ecto.Changeset

  @fields [
    :category_id,
    :manufacturer_id,
    :product_ids,
    :name,
    :reference,
    :description,
    :image,
    :average_lifetime_m,
    :country_of_origin,
    :start_of_production,
    :end_of_production,
    :main_material
  ]

  @required_fields [
    :manufacturer_id,
    :name,
    :reference
  ]

  schema "parts" do
    field :average_lifetime_m, :integer
    field :country_of_origin, :string
    field :description, :string
    field :end_of_production, :date
    field :image, :string
    field :main_material, :string
    field :name, :string
    field :reference, :string
    field :start_of_production, :date

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(part, attrs) do
    part
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:reference)
  end
end
