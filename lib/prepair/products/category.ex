defmodule Prepair.Products.Category do
  use Ecto.Schema
  import Ecto.Changeset

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
    |> cast(attrs, [:name, :description, :image, :average_lifetime_m])
    |> validate_required([:name, :description, :image, :average_lifetime_m])
    |> unique_constraint(:name)
  end
end
