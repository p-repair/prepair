defmodule Prepair.Products.Category do
  use Ecto.Schema
  import Ecto.Changeset

  @fields [
    :average_lifetime_m,
    :description,
    :image,
    :name
  ]

  @required_fields [:name]

  schema "categories" do
    field :average_lifetime_m, :integer
    field :description, :string
    field :image, :string
    field :name, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:name)
  end
end
