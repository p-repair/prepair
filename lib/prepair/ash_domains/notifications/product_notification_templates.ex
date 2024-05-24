defmodule Prepair.AshDomains.Notifications.ProductNotificationTemplates do
  use Ash.Resource,
    domain: Prepair.AshDomains.Notifications,
    data_layer: AshPostgres.DataLayer

  alias Prepair.AshDomains.Notifications.NotificationTemplate
  alias Prepair.AshDomains.Products.Product

  postgres do
    table "product_notification_templates"
    repo Prepair.Repo

    references do
      reference :product, on_delete: :delete
      reference :notification_template, on_delete: :delete
    end

    custom_indexes do
      index :product_id, unique: false
      index :notification_template_id, unique: false
    end
  end

  relationships do
    belongs_to :product, Product do
      source_attribute :product_id
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
end
