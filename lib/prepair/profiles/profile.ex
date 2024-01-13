defmodule Prepair.Profiles.Profile do
  use Ecto.Schema

  alias Prepair.Accounts.User

  import Ecto.Changeset

  @fields [
    :username,
    :newsletter,
    :people_in_household
  ]

  @required_fields @fields

  @primary_key {:id, :id, autogenerate: false}
  schema "profiles" do
    belongs_to :user, User, foreign_key: :id, define_field: false

    field :username, :string
    field :newsletter, :boolean
    field :people_in_household, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(profile, attrs) do
    profile
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:username)
  end
end
