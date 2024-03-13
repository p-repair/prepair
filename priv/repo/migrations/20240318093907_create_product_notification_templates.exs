defmodule Prepair.Repo.Migrations.CreateProductNotificationTemplates do
  use Ecto.Migration

  def change do
    create table(:product_notification_templates, primary_key: false) do
      add :product_id, references(:products, on_delete: :delete_all)

      add :notification_template_id,
          references(:notification_templates, on_delete: :delete_all)
    end

    create unique_index(:product_notification_templates, [
             :product_id,
             :notification_template_id
           ])

    create index(:product_notification_templates, [:product_id])
    create index(:product_notification_templates, [:notification_template_id])
  end
end
