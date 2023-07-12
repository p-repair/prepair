defmodule Prepair.Repo.Migrations.CreateManufacturers do
  use Ecto.Migration

  def change do
    create table(:manufacturers) do
      add :name, :string, null: false
      add :description, :string
      add :image, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:manufacturers, [:name])
  end
end
