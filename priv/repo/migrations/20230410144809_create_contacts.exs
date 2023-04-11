defmodule PrepairLandingPage.Repo.Migrations.CreateContacts do
  use Ecto.Migration

  def change do
    create table(:contacts) do
      add :email, :string, null: false
      add :lang, :string
      add :mailerlite_id, :integer

      timestamps(type: :utc_datetime)
    end

    create unique_index(:contacts, [:email])
  end
end
