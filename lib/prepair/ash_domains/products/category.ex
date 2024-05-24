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

  code_interface do
    define :list, action: :read
    define :list_by_id, args: [:ids]
    define :get, args: [:id]
    define :create
    define :update
    define :delete, action: :destroy
  end

  actions do
    default_accept [:average_lifetime_m, :description, :image, :name]
    defaults [:read, :destroy]

    read :list_by_id do
      argument :ids, {:array, :uuid}
      filter expr(id in ^arg(:ids))
    end

    # NOTE: Maybe we don’t need to keep the preload of the notification_templates
    read :get do
      get_by :id
      prepare build(load: :notification_templates)
    end

    create :create do
      primary? true
      argument :notification_template_ids, {:array, :uuid}

      change manage_relationship(
               :notification_template_ids,
               :notification_templates,
               type: :append_and_remove,
               on_no_match: :ignore
             )
    end

    update :update do
      primary? true
      argument :notification_template_ids, {:array, :uuid}

      # TODO: mieux comprendre l’erreur lorsque l’on enlève la ligne ci-dessous
      # https://elixirforum.com/t/run-into-problems-with-ash-postgress-2-0-rc-ash-error-framework-framework-error/63063/3
      require_atomic? false

      change manage_relationship(
               :notification_template_ids,
               :notification_templates,
               type: :append_and_remove,
               on_no_match: :ignore
             )
    end
  end
end
