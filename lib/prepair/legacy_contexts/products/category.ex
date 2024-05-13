defmodule Prepair.LegacyContexts.Products.Category do
  use Ecto.Schema
  import Ecto.Changeset

  alias Prepair.LegacyContexts.Notifications.NotificationTemplate
  alias Prepair.LegacyContexts.Products.{Product, Part}

  @required_fields [:name]

  @fields @required_fields ++
            [
              :notification_template_ids,
              :average_lifetime_m,
              :description,
              :image
            ]

  @derive {Phoenix.Param, key: :id}
  @primary_key {:id, Ecto.UUID, autogenerate: false}
  schema "categories" do
    has_many :products, Product,
      foreign_key: :category_id,
      references: :id

    has_many :parts, Part,
      foreign_key: :category_id,
      references: :id

    many_to_many :notification_templates, NotificationTemplate,
      join_through: "category_notification_templates",
      join_keys: [category_id: :id, notification_template_id: :id],
      on_replace: :delete

    field :notification_template_ids, {:array, Ecto.UUID},
      virtual: true,
      default: []

    field :average_lifetime_m, :integer
    field :description, :string
    field :image, :string
    field :name, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:name)
  end
end
