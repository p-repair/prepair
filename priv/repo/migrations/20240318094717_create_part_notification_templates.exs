defmodule Prepair.Repo.Migrations.CreatePartNotificationTemplates do
  use Ecto.Migration

  def change do
    create table(:part_notification_templates, primary_key: false) do
      add :part_id, references(:parts, on_delete: :delete_all)

      add :notification_template_id,
          references(:notification_templates, on_delete: :delete_all)
    end

    create unique_index(:part_notification_templates, [
             :part_id,
             :notification_template_id
           ])

    create index(:part_notification_templates, [:part_id])
    create index(:part_notification_templates, [:notification_template_id])
  end
end
