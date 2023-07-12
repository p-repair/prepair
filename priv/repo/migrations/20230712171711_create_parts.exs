defmodule Prepair.Repo.Migrations.CreateParts do
  use Ecto.Migration

  def change do
    create table(:parts) do
      add :name, :string
      add :reference, :string
      add :description, :string
      add :image, :string
      add :average_lifetime_m, :integer
      add :country_of_origin, :string
      add :main_material, :string
      add :start_of_production, :date
      add :end_of_production, :date

      timestamps(type: :utc_datetime)
    end

    create unique_index(:parts, [:reference])
  end
end
