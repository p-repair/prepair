defmodule Prepair.AshDomains.Accounts.User do
  use Ash.Resource,
    domain: Prepair.AshDomains.Accounts,
    data_layer: AshPostgres.DataLayer

  alias Prepair.AshDomains.Profiles.Profile

  postgres do
    table "users"
    repo Prepair.Repo

    custom_statements do
      statement :users_id_fkey do
        up "ALTER TABLE ONLY public.users
            ADD CONSTRAINT users_id_fkey FOREIGN KEY (id)
            REFERENCES public.profiles(id)
            ON DELETE CASCADE
            DEFERRABLE INITIALLY DEFERRED;"
        down "DROP CONSTRAINT users_id_fkey"
      end

      statement :create_citext_extension do
        up "CREATE EXTENSION IF NOT EXISTS citext;"
        down "DROP EXTENSION IF EXISTS citext;"
      end

      statement :email_type do
        up "ALTER TABLE ONLY public.users
            ALTER COLUMN email
            SET DATA TYPE CITEXT;"
        down "ALTER TABLE ONLY public.users
            ALTER COLUMN email
            SET DATA TYPE TEXT;"
      end

      statement :role_type do
        up "ALTER TABLE ONLY public.users
            ALTER COLUMN role
            SET DATA TYPE VARCHAR(15);"
        down "ALTER TABLE ONLY public.users
            ALTER COLUMN role
            SET DATA TYPE VARCHAR;"
      end
    end

    # This reference doesn’t work
    # references do
    #   reference :profile,
    #     on_delete: :delete,
    #     deferrable: :initially,
    #     match_with: [id: :id],
    #     name: "users_id_fkey"
    # end

    migration_types hashed_password: :string,
                    role: :string
  end

  attributes do
    uuid_primary_key :id

    attribute :email, :string do
      allow_nil? false
      public? true
      constraints match: ~r/^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+.[a-zA-Z0-9-.]+$/
    end

    attribute :hashed_password, :string do
      allow_nil? false
      sensitive? true
      public? false
    end

    attribute :role, :atom do
      allow_nil? false
      constraints one_of: [:user, :admin]
      default :user
    end

    attribute :confirmed_at, :naive_datetime
    create_timestamp :inserted_at, type: :utc_datetime
    update_timestamp :updated_at, type: :utc_datetime
  end

  relationships do
    has_one :profile, Profile do
      source_attribute :id
      destination_attribute :id
    end
  end

  identities do
    identity :email, [:email]
  end
end
