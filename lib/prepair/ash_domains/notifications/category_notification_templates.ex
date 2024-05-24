defmodule Prepair.AshDomains.Notifications.CategoryNotificationTemplates do
  use Ash.Resource,
    domain: Prepair.AshDomains.Notifications,
    data_layer: AshPostgres.DataLayer

  alias Prepair.AshDomains.Notifications.NotificationTemplate
  alias Prepair.AshDomains.Products.Category

  postgres do
    table "category_notification_templates"
    repo Prepair.Repo

    references do
      reference :category, on_delete: :delete
      reference :notification_template, on_delete: :delete
    end

    custom_indexes do
      index :category_id, unique: false
      index :notification_template_id, unique: false
    end
  end

  relationships do
    belongs_to :category, Category do
      source_attribute :category_id
      destination_attribute :id
      primary_key? true
      allow_nil? false
    end

    belongs_to :notification_template, NotificationTemplate do
      source_attribute :notification_template_id
      destination_attribute :id
      primary_key? true
      allow_nil? false
    end
  end

  actions do
    defaults [:create, :read, :destroy]
  end
end
