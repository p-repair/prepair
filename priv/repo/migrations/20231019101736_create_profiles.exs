defmodule Prepair.Repo.Migrations.CreateProfiles do
  use Ecto.Migration

  def change do
    create table(:profiles) do
      add :username, :string, null: false
      add :newsletter, :boolean, null: false
      add :people_in_household, :integer, null: false

      timestamps(type: :utc_datetime)
    end

    execute(
      # UP
      "INSERT INTO profiles
            (id, username, people_in_household, newsletter, inserted_at, updated_at)
            SELECT id, email, 1, false, inserted_at, CURRENT_TIMESTAMP(0)
            FROM users;",

      # DOWN
      "DELETE FROM profiles;"
    )

    execute(
      # UP
      "ALTER TABLE users
            ADD FOREIGN KEY (id) REFERENCES profiles (id) ON DELETE CASCADE
            DEFERRABLE INITIALLY DEFERRED;",

      # DOWN
      "ALTER TABLE users DROP CONSTRAINT users_id_fkey;"
    )

    execute(
      # UP
      "ALTER TABLE profiles
            ADD FOREIGN KEY (id) REFERENCES users (id) ON DELETE CASCADE;",

      # DOWN
      "ALTER TABLE profiles DROP CONSTRAINT profiles_id_fkey;"
    )

    create unique_index(:profiles, [:username])
  end
end
