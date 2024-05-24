defmodule Prepair.AshDomains.Notifications.NotificationTemplate do
  use Ash.Resource,
    domain: Prepair.AshDomains.Notifications,
    data_layer: AshPostgres.DataLayer

  alias Prepair.AshDomains.Notifications.{
    CategoryNotificationTemplates,
    ProductNotificationTemplates,
    PartNotificationTemplates
  }

  alias Prepair.AshDomains.Products.{Category, Product, Part}

  postgres do
    table "notification_templates"
    repo Prepair.Repo

    migration_types condition: :string,
                    content: :string,
                    description: :string,
                    name: :string,
                    title: :string
  end

  attributes do
    uuid_primary_key :id
    attribute :condition, :string, allow_nil?: false
    attribute :content, :string, allow_nil?: false
    attribute :description, :string
    attribute :draft, :boolean, allow_nil?: false, default: true
    attribute :name, :string, allow_nil?: false
    attribute :need_action, :boolean, allow_nil?: false
    attribute :title, :string, allow_nil?: false
    create_timestamp :inserted_at, type: :utc_datetime
    update_timestamp :updated_at, type: :utc_datetime
  end

  relationships do
    has_many :categories_join_assoc,
             Prepair.AshDomains.Notifications.CategoryNotificationTemplates do
      domain Notifications
    end

    many_to_many :categories, Category do
      through CategoryNotificationTemplates
      source_attribute_on_join_resource :notification_template_id
      destination_attribute_on_join_resource :category_id
    end

    has_many :products_join_assoc,
             Prepair.AshDomains.Notifications.ProductNotificationTemplates do
      domain Notifications
    end

    many_to_many :products, Product do
      through ProductNotificationTemplates
      source_attribute_on_join_resource :notification_template_id
      destination_attribute_on_join_resource :product_id
    end

    has_many :parts_join_assoc,
             Prepair.AshDomains.Notifications.PartNotificationTemplates do
      domain Notifications
    end

    many_to_many :parts, Part do
      through PartNotificationTemplates
      source_attribute_on_join_resource :notification_template_id
      destination_attribute_on_join_resource :part_id
    end
  end

  identities do
    identity :name, [:name]
  end
end
