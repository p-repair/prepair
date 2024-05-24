defmodule Prepair.AshDomains.Notifications.NotificationTemplate do
  use Ash.Resource,
    domain: Prepair.AshDomains.Notifications,
    data_layer: AshPostgres.DataLayer

  alias Prepair.AshDomains.Notifications

  alias Prepair.AshDomains.Notifications.{
    CategoryNotificationTemplates,
    ProductNotificationTemplates,
    PartNotificationTemplates
  }

  alias Prepair.AshDomains.Products.{Category, Product, Part}
  require Ash.Query

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

  code_interface do
    define :list
    define :list_by_id, args: [:ids]
    define :get, args: [:id]
    define :create
    define :update
    define :delete, action: :destroy
  end

  actions do
    default_accept [
      :condition,
      :content,
      :description,
      :draft,
      :name,
      :need_action,
      :title
    ]

    defaults [:read, :destroy]

    read :list do
      primary? true
      argument :category_ids, {:array, :uuid}
      argument :product_ids, {:array, :uuid}
      argument :part_ids, {:array, :uuid}

      prepare fn query, _ ->
        case Ash.Query.fetch_argument(query, :category_ids) do
          {:ok, value} when is_list(value) ->
            Ash.Query.filter(query, categories.id in ^value)

          _ ->
            query
        end
      end

      prepare fn query, _ ->
        case Ash.Query.fetch_argument(query, :product_ids) do
          {:ok, value} when is_list(value) ->
            Ash.Query.filter(query, products.id in ^value)

          _ ->
            query
        end
      end

      prepare fn query, _ ->
        case Ash.Query.fetch_argument(query, :part_ids) do
          {:ok, value} when is_list(value) ->
            Ash.Query.filter(query, parts.id in ^value)

          _ ->
            query
        end
      end

      prepare build(sort: [:inserted_at])
    end

    read :list_by_id do
      argument :ids, {:array, :uuid}
      filter expr(id in ^arg(:ids))
    end

    read :get do
      get_by :id
      prepare build(load: [:categories, :parts, :products])
    end

    create :create do
      primary? true
      argument :category_ids, {:array, :uuid}
      argument :product_ids, {:array, :uuid}
      argument :part_ids, {:array, :uuid}

      change manage_relationship(
               :category_ids,
               :categories,
               type: :append_and_remove,
               on_no_match: :ignore
             )

      change manage_relationship(
               :product_ids,
               :products,
               type: :append_and_remove,
               on_no_match: :ignore
             )

      change manage_relationship(
               :part_ids,
               :parts,
               type: :append_and_remove,
               on_no_match: :ignore
             )
    end

    update :update do
      primary? true
      argument :category_ids, {:array, :uuid}
      argument :product_ids, {:array, :uuid}
      argument :part_ids, {:array, :uuid}
      require_atomic? false

      change manage_relationship(
               :category_ids,
               :categories,
               type: :append_and_remove,
               on_no_match: :ignore
             )

      change manage_relationship(
               :product_ids,
               :products,
               type: :append_and_remove,
               on_no_match: :ignore
             )

      change manage_relationship(
               :part_ids,
               :parts,
               type: :append_and_remove,
               on_no_match: :ignore
             )
    end
  end
end
