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

  code_interface do
    define :list, action: :read
    define :list_by_id
    define :get, args: [:id]
    define :create
    define :update
    define :delete, action: :destroy
  end

  actions do
    default_accept [
      :average_lifetime_m,
      :category_id,
      :country_of_origin,
      :description,
      :end_of_production,
      :image,
      :main_material,
      :manufacturer_id,
      :name,
      :reference,
      :start_of_production
    ]

    defaults [:read, :destroy]

    read :list_by_id do
      argument :id, {:array, :uuid}
      filter expr(id in ^arg(:id))
    end

    read :get do
      get_by :id

      prepare build(
                load: [
                  :category,
                  :manufacturer,
                  :products,
                  :notification_templates
                ]
              )
    end

    create :create do
      primary? true
      argument :product_ids, {:array, :uuid}
      argument :notification_template_ids, {:array, :uuid}

      change manage_relationship(
               :product_ids,
               :products,
               type: :append_and_remove,
               on_no_match: :ignore
             )

      change manage_relationship(
               :notification_template_ids,
               :notification_templates,
               type: :append_and_remove,
               on_no_match: :ignore
             )
    end

    update :update do
      primary? true
      argument :product_ids, {:array, :uuid}
      argument :notification_template_ids, {:array, :uuid}
      require_atomic? false

      change manage_relationship(
               :product_ids,
               :products,
               type: :append_and_remove,
               on_no_match: :ignore
             )

      change manage_relationship(
               :notification_template_ids,
               :notification_templates,
               type: :append_and_remove,
               on_no_match: :ignore
             )
    end
  end
end
