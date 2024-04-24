defmodule Prepair.Products.Product do
  use Ecto.Schema

  alias Prepair.Notifications.NotificationTemplate
  alias Prepair.Products.{Manufacturer, Category, Part}
  alias Prepair.Profiles.Ownership

  import Ecto.Changeset

  @required_fields [
    :category_id,
    :manufacturer_id,
    :name,
    :reference
  ]

  @fields @required_fields ++
            [
              :part_ids,
              :notification_template_ids,
              :description,
              :image,
              :average_lifetime_m,
              :country_of_origin,
              :start_of_production,
              :end_of_production
            ]

  @derive {Phoenix.Param, key: :id}
  @primary_key {:id, Ecto.UUID, autogenerate: false}
  schema "products" do
    belongs_to :category, Category,
      foreign_key: :category_id,
      references: :id,
      type: Ecto.UUID

    belongs_to :manufacturer, Manufacturer,
      foreign_key: :manufacturer_id,
      references: :id,
      type: Ecto.UUID

    many_to_many :parts, Part,
      join_through: "product_parts",
      join_keys: [product_id: :id, part_id: :id],
      on_replace: :delete

    many_to_many :notification_templates, NotificationTemplate,
      join_through: "product_notification_templates",
      join_keys: [product_id: :id, notification_template_id: :id],
      on_replace: :delete

    has_many :ownerships, Ownership,
      foreign_key: :product_id,
      references: :id

    field :part_ids, {:array, Ecto.UUID}, virtual: true, default: []

    field :notification_template_ids, {:array, Ecto.UUID},
      virtual: true,
      default: []

    field :average_lifetime_m, :integer
    field :country_of_origin, :string
    field :description, :string
    field :end_of_production, :date
    field :image, :string
    field :name, :string
    field :reference, :string
    field :start_of_production, :date

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
    |> unique_constraint([:reference, :manufacturer_id])
  end
end
