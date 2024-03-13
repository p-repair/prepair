defmodule Prepair.Products.Part do
  use Ecto.Schema
  import Ecto.Changeset

  alias Prepair.Notifications.NotificationTemplate
  alias Prepair.Products.{Category, Manufacturer, Product}

  @required_fields [
    :manufacturer_id,
    :name,
    :reference
  ]

  @fields @required_fields ++
            [
              :category_id,
              :product_ids,
              :notification_template_ids,
              :description,
              :image,
              :average_lifetime_m,
              :country_of_origin,
              :start_of_production,
              :end_of_production,
              :main_material
            ]

  @primary_key {:id, :id, autogenerate: true}
  schema "parts" do
    belongs_to :category, Category, foreign_key: :category_id
    belongs_to :manufacturer, Manufacturer, foreign_key: :manufacturer_id

    many_to_many :products, Product,
      join_through: "product_parts",
      join_keys: [part_id: :id, product_id: :id],
      on_replace: :delete

    many_to_many :notification_templates, NotificationTemplate,
      join_through: "part_notification_templates",
      join_keys: [part_id: :id, notification_template_id: :id],
      on_replace: :delete

    field :product_ids, {:array, :integer}, virtual: true, default: []

    field :notification_template_ids, {:array, :integer},
      virtual: true,
      default: []

    field :average_lifetime_m, :integer
    field :country_of_origin, :string
    field :description, :string
    field :end_of_production, :date
    field :image, :string
    field :main_material, :string
    field :name, :string
    field :reference, :string
    field :start_of_production, :date

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(part, attrs) do
    part
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
    |> unique_constraint([:reference, :manufacturer_id])
  end
end
