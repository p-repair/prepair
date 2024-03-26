defmodule Prepair.Products.Manufacturer do
  use Ecto.Schema
  import Ecto.Changeset

  alias Prepair.Products.{Product, Part}

  @required_fields [:name]

  @fields @required_fields ++ [:description, :image]

  @derive {Phoenix.Param, key: :uuid}
  @primary_key {:uuid, Ecto.UUID, autogenerate: false}
  schema "manufacturers" do
    has_many :products, Product,
      foreign_key: :manufacturer_uuid,
      references: :uuid

    has_many :parts, Part,
      foreign_key: :manufacturer_uuid,
      references: :uuid

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
