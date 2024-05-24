defmodule Prepair.LegacyContexts.Profiles.Profile do
  use Ecto.Schema

  alias Prepair.LegacyContexts.Accounts.User
  alias Prepair.LegacyContexts.Profiles.Ownership

  import Ecto.Changeset

  @required_fields [
    :username,
    :newsletter,
    :people_in_household
  ]

  @fields @required_fields

  @derive {Phoenix.Param, key: :id}
  @primary_key {:id, Ecto.UUID, autogenerate: false}
  schema "profiles" do
    belongs_to :user, User,
      foreign_key: :id,
      references: :id,
      define_field: false

    has_many :ownerships, Ownership,
      foreign_key: :profile_id,
      references: :id

    field :username, :string
    field :newsletter, :boolean
    field :people_in_household, :integer

    timestamps(type: :utc_datetime)
  end

  def changeset(profile, attrs) do
    profile
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:username)
  end

  def registration_changeset(user_and_profile, attrs) do
    user_and_profile
    |> cast(attrs, @fields)
    |> cast_assoc(:user, with: &User.registration_changeset/2)
    |> validate_required(@required_fields)
    |> unique_constraint(:username)
  end
end