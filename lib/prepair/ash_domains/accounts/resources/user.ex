defmodule Prepair.AshDomains.Accounts.User do
  use Ash.Resource,
    domain: Prepair.AshDomains.Accounts,
    data_layer: AshPostgres.DataLayer

  alias Prepair.AshDomains.Profiles.Profile
  alias Prepair.AshDomains.Accounts.{User, Registration}

  import Prepair.AshDomains.ValidationMacros
  import PrepairWeb.Gettext

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

  code_interface do
    define :list, action: :read
    define :get_by_email, args: [:email]
  end

  actions do
    defaults [:update, :destroy]

    read :read do
      primary? true
      prepare build(load: :profile)
    end

    read :get_by_email do
      argument :email, :string, allow_nil?: false
      filter expr(email == ^arg(:email))
      prepare build(load: :profile)
    end

    create :register do
      accept [:email, :role]
      argument :password, :string, allow_nil?: false
      argument :password_confirmation, :string, allow_nil?: false
    end
  end

  validations do
    validate_email()
    validate_password()
  end

  # -------------------------------------------------------------------------- #
  #                              Helper functions                              #
  # -------------------------------------------------------------------------- #

  def register_user(registration_attrs) do
    changeset =
      Registration
      |> Ash.Changeset.for_create(:register, registration_attrs,
        domain: Registration
      )

    strategy =
      AshAuthentication.Info.strategy!(User, :password)

    if(changeset.valid?) do
      Repo.transaction(fn ->
        with {:ok, user} <-
               AshAuthentication.Strategy.action(
                 strategy,
                 :register,
                 filter_user_attrs(registration_attrs)
               ),
             {:ok, _profile} <-
               Profile
               |> Ash.Changeset.for_create(
                 :create,
                 Map.put(registration_attrs, :id, user.id),
                 skip_unknown_inputs: [
                   :email,
                   :password,
                   :password_confirmation,
                   :role
                 ]
               )
               |> Ash.create() do
          Ash.get!(User, user.id, load: :profile)
        else
          {:error, value} -> Repo.rollback(value)
        end
      end)
    else
      {:error, changeset}
    end
  end

  defp filter_user_attrs(params) do
    Enum.reduce(params, %{}, fn {k, v}, acc ->
      if k in [:email, :password, :password_confirmation, :role],
        do: Map.put(acc, k, v),
        else: acc
    end)
  end
end
