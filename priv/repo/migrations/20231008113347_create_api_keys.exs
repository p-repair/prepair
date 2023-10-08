defmodule Prepair.Repo.Migrations.CreateApiKeys do
  use Ecto.Migration

  def change do
    create table(:api_keys) do
      add :name, :string, null: false
      # NOTE: API keys are 256-bit random numbers encoded in Base64, hence 44
      # characters.
      add :key, :string, size: 44, null: false
      add :revoked_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create unique_index(:api_keys, [:name])
    create index(:api_keys, [:key])
  end
end
