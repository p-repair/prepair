defmodule Prepair.Auth.ApiKey do
  use TypedEctoSchema

  import Ecto.Changeset

  @fields ~w(name key revoked_at)a
  @required_fields ~w(name key)a

  @derive {Phoenix.Param, key: :id}
  @primary_key {:id, Ecto.UUID, autogenerate: false}
  typed_schema "api_keys" do
    field :name, :string, enforce: true, null: false
    field :key, :string, enforce: true, null: false
    field :revoked_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @doc false
  @spec changeset(t(), map()) :: Changeset.t()
  def changeset(api_key, attrs) do
    api_key
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:name)
  end
end
