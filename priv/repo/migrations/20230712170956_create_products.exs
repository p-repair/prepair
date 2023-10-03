defmodule Prepair.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :name, :string
      add :reference, :string
      add :description, :string
      add :image, :string
      add :average_lifetime_m, :integer
      add :country_of_origin, :string
      add :start_of_production, :date
      add :end_of_production, :date
      add :manufacturer_id, references(:manufacturers, on_delete: :delete_all)
      add :category_id, references(:categories, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:products, [:reference, :manufacturer_id])
    create index(:products, [:name])
    create index(:products, [:manufacturer_id])
    create index(:products, [:category_id])
  end
end
