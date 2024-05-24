defmodule Prepair.AshDomains.Products.Part do
  use Ash.Resource,
    domain: Prepair.AshDomains.Products,
    data_layer: AshPostgres.DataLayer

  alias Prepair.AshDomains.Notifications.{
    NotificationTemplate,
    PartNotificationTemplates
  }

  alias Prepair.AshDomains.Products.{
    Category,
    Manufacturer,
    Product,
    ProductParts
  }

  postgres do
    table "parts"
    repo Prepair.Repo

    references do
      reference :category, on_delete: :delete
      reference :manufacturer, on_delete: :delete
    end

    custom_indexes do
      index :name, unique: false
    end

    migration_types average_lifetime_m: :integer,
                    country_of_origin: :string,
                    description: :string,
                    image: :string,
                    main_material: :string,
                    name: :string,
                    reference: :string
  end

  attributes do
    uuid_primary_key :id
    attribute :average_lifetime_m, :integer
    attribute :country_of_origin, :string
    attribute :description, :string
    attribute :end_of_production, :date
    attribute :image, :string
    attribute :main_material, :string
    attribute :name, :string, allow_nil?: false
    attribute :reference, :string, allow_nil?: false
    attribute :start_of_production, :date
    create_timestamp :inserted_at, type: :utc_datetime
    update_timestamp :updated_at, type: :utc_datetime
  end

  relationships do
    belongs_to :category, Category do
      source_attribute :category_id
      destination_attribute :id
    end

    belongs_to :manufacturer, Manufacturer do
      source_attribute :manufacturer_id
      destination_attribute :id
    end

    many_to_many :products, Product do
      through ProductParts
      source_attribute_on_join_resource :part_id
      destination_attribute_on_join_resource :product_id
    end

    many_to_many :notification_templates, NotificationTemplate do
      through PartNotificationTemplates
      source_attribute_on_join_resource :part_id
      destination_attribute_on_join_resource :notification_template_id
    end
  end

  identities do
    identity :reference_manufacturer_id, [:reference, :manufacturer_id]
  end
end
