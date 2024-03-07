defmodule Prepair.Repo.Migrations.CreateOwnerships do
  use Ecto.Migration

  def change do
    create table(:ownerships) do
      add :date_of_purchase, :date, null: false
      add :warranty_duration_m, :integer
      add :price_of_purchase, :integer
      add :public, :boolean, null: false, default: false
      add :product_id, references(:products, on_delete: :delete_all)
      add :profile_id, references(:profiles, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:ownerships, [:product_id])
    create index(:ownerships, [:profile_id])
  end
end
