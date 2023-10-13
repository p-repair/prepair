defmodule Prepair.Repo.Migrations.AddRoleToUsers do
  use Ecto.Migration

  def up do
    alter table(:users) do
      # Set the role to user to exisisting users.
      add :role, :string, size: 15, null: false, default: "user"
    end

    alter table(:users) do
      # Remove the default value for newly added usesr.
      modify :role, :string, size: 15, null: false, default: nil
    end
  end

  def down do
    alter table(:users) do
      remove :role, :string, size: 15, null: false
    end
  end
end
