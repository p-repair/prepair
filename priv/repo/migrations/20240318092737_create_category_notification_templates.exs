defmodule Prepair.Repo.Migrations.CreateCategoryNotificationTemplates do
  use Ecto.Migration

  def change do
    create table(:category_notification_templates, primary_key: false) do
      add :category_id, references(:categories, on_delete: :delete_all)

      add :notification_template_id,
          references(:notification_templates, on_delete: :delete_all)
    end

    create unique_index(:category_notification_templates, [
             :category_id,
             :notification_template_id
           ])

    create index(:category_notification_templates, [:category_id])
    create index(:category_notification_templates, [:notification_template_id])
  end
end
