defmodule Prepair.Repo.Migrations.CreateProductParts do
  use Ecto.Migration

  def change do
    create table(:product_parts, primary_key: false) do
      add :product_id, references(:products, on_delete: :delete_all)
      add :part_id, references(:parts, on_delete: :delete_all)
    end

    create unique_index(:product_parts, [:part_id, :product_id])
    create index(:product_parts, [:product_id])
    create index(:product_parts, [:part_id])
  end
end
