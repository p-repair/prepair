defmodule Prepair.Repo.Migrations.CreateNotificationTemplates do
  use Ecto.Migration

  def change do
    create table(:notification_templates) do
      add :name, :string, null: false
      add :title, :string, null: false
      add :content, :string, null: false
      add :description, :string
      add :condition, :string, null: false
      add :need_action, :boolean, null: false
      add :draft, :boolean, default: true, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:notification_templates, [:name])
  end
end
