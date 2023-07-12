defmodule Prepair.Products.Part do
  use Ecto.Schema
  import Ecto.Changeset

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
    |> cast(attrs, [
      :name,
      :reference,
      :description,
      :image,
      :average_lifetime_m,
      :country_of_origin,
      :main_material,
      :start_of_production,
      :end_of_production
    ])
    |> validate_required([
      :name,
      :reference,
      :description,
      :image,
      :average_lifetime_m,
      :country_of_origin,
      :main_material,
      :start_of_production,
      :end_of_production
    ])
    |> unique_constraint(:reference)
  end
end
