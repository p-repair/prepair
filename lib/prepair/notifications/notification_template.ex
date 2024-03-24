defmodule Prepair.Notifications.NotificationTemplate do
  use Ecto.Schema
  import Ecto.Changeset

  alias Prepair.Products.{Category, Part, Product}

  @required_fields [
    :name,
    :title,
    :content,
    :condition,
    :need_action
  ]

  @fields @required_fields ++
            [
              :category_ids,
              :product_ids,
              :part_ids,
              :description,
              :draft
            ]

  @primary_key {:id, :id, autogenerate: true}
  schema "notification_templates" do
    many_to_many :categories, Category,
      join_through: "category_notification_templates",
      join_keys: [notification_template_id: :id, category_id: :id],
      on_replace: :delete

    many_to_many :products, Product,
      join_through: "product_notification_templates",
      join_keys: [notification_template_id: :id, product_id: :id],
      on_replace: :delete

    many_to_many :parts, Part,
      join_through: "part_notification_templates",
      join_keys: [notification_template_id: :id, part_id: :id],
      on_replace: :delete

    field :category_ids, {:array, :integer}, virtual: true, default: []
    field :product_ids, {:array, :integer}, virtual: true, default: []
    field :part_ids, {:array, :integer}, virtual: true, default: []
    field :name, :string
    field :description, :string
    field :title, :string
    field :content, :string
    field :condition, :string
    field :need_action, :boolean
    field :draft, :boolean, default: true

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(notification_template, attrs) do
    notification_template
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:name)
  end
end
