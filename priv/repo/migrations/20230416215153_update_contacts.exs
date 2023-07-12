defmodule Prepair.Repo.Migrations.UpdateContacts do
  use Ecto.Migration

  def change do
    alter table(:contacts) do
      modify :mailerlite_id, :bigint
    end
  end
end
