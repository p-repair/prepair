defmodule Prepair.Products.Manufacturer do
  use Ecto.Schema
  import Ecto.Changeset

  alias Prepair.Products.{Product, Part}

  @required_fields [:name]

  @fields @required_fields ++ [:description, :image]

  @primary_key {:id, :id, autogenerate: true}
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
