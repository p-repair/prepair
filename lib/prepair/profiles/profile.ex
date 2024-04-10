defmodule Prepair.Profiles.Profile do
  use Ecto.Schema

  alias Prepair.Accounts.User
  alias Prepair.Profiles.Ownership

  import Ecto.Changeset

  @required_fields [
    :username,
    :newsletter,
    :people_in_household
  ]

  @fields @required_fields

  @derive {Phoenix.Param, key: :uuid}
  @primary_key {:uuid, Ecto.UUID, autogenerate: false}
  schema "profiles" do
    belongs_to :user, User,
      foreign_key: :uuid,
      references: :uuid,
      define_field: false

    has_many :ownerships, Ownership,
      foreign_key: :profile_uuid,
      references: :uuid

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
