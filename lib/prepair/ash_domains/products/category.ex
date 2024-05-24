defmodule Prepair.AshDomains.Products.Category do
  use Ash.Resource,
    domain: Prepair.AshDomains.Products,
    data_layer: AshPostgres.DataLayer

  alias Prepair.AshDomains.Notifications.{
    NotificationTemplate,
    CategoryNotificationTemplates
  }

  alias Prepair.AshDomains.Products.{Product, Part}

  postgres do
    table "categories"
    repo Prepair.Repo

    migration_types average_lifetime_m: :integer,
                    description: :string,
                    image: :string,
                    name: :string
  end

  attributes do
    uuid_primary_key :id
    attribute :average_lifetime_m, :integer
    attribute :description, :string
    attribute :image, :string
    attribute :name, :string, allow_nil?: false, writable?: true
    create_timestamp :inserted_at, type: :utc_datetime
    update_timestamp :updated_at, type: :utc_datetime
  end

  relationships do
    has_many :products, Product do
      source_attribute :id
      destination_attribute :category_id
    end

    has_many :parts, Part do
      source_attribute :id
      destination_attribute :category_id
    end

    many_to_many :notification_templates, NotificationTemplate do
      through CategoryNotificationTemplates
      source_attribute_on_join_resource :category_id
      destination_attribute_on_join_resource :notification_template_id
    end
  end

  identities do
    identity :name, [:name]
  end
end
