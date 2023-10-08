defmodule Prepair.Products.Manufacturer do
  use Ecto.Schema
  import Ecto.Changeset

  alias Prepair.Products.{Product, Part}

  @fields [:name, :description, :image]
  @required_fields [:name]

  schema "manufacturers" do
    has_many :products, Product
    has_many :parts, Part

    field :description, :string
    field :image, :string
    field :name, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(manufacturer, attrs) do
    manufacturer
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:name)
  end
end