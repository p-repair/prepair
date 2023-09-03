defmodule Prepair.Products.Product do
  use Ecto.Schema
  import Ecto.Changeset

  alias Prepair.Products.{Manufacturer, Category, Part}

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
    belongs_to :category, Category
    belongs_to :manufacturer, Manufacturer

    many_to_many :parts, Part,
      join_through: "product_parts",
      on_replace: :delete

    field :part_ids, {:array, :integer}, virtual: true, default: []
    field :average_lifetime_m, :integer
    field :country_of_origin, :string
    field :description, :string
    field :end_of_production, :date
    field :image, :string
    field :name, :string
    field :reference, :string
    field :start_of_production, :date

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
    |> unique_constraint([:reference, :manufacturer_id])
  end
end
