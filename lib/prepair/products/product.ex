defmodule Prepair.Products.Product do
  use Ecto.Schema

  alias Prepair.Products.{Manufacturer, Category, Part}
  alias Prepair.Profiles.Ownership

  import Ecto.Changeset

  @required_fields [
    :category_id,
    :manufacturer_id,
    :name,
    :reference
  ]

  @fields @required_fields ++
            [
              :part_ids,
              :description,
              :image,
              :average_lifetime_m,
              :country_of_origin,
              :start_of_production,
              :end_of_production
            ]

  @primary_key {:id, :id, autogenerate: true}
  schema "products" do
    belongs_to :category, Category
    belongs_to :manufacturer, Manufacturer

    many_to_many :parts, Part,
      join_through: "product_parts",
      on_replace: :delete

    has_many :ownerships, Ownership

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
