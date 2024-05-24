defmodule Prepair.Repo.Migrations.MigrateToAsh do
  @moduledoc """
  Migration to Ash resources.
  The generated code has been adapdted, but the database state represents
  what’s written in Ash resources at migration date and time.
  """

  use Ecto.Migration

  def up do
    correct_index_name()
    add_new_default_role_for_users_at_db_level()
    add_primary_keys_for_join_tables()
    add_not_null_constraints_on_attributes_at_db_level()
    add_default_timestamps_at_db_level()
  end

  def down do
    remove_default_timestamps_at_db_level()
    remove_new_not_null_constraints_on_attributes_at_db_level()
    remove_primary_keys_for_join_tables()
    remove_new_default_role_for_users()
  end

  # -------------------------------------------------------------------------- #
  #                           MIGRATION UP FUNCTIONS                           #
  # -------------------------------------------------------------------------- #

  def correct_index_name do
    execute "
    DROP INDEX IF EXISTS category_notification_templates_notification_template_id_inde;
    "

    create_if_not_exists index(:category_notification_templates, [
                           :notification_template_id
                         ])
  end

  def add_new_default_role_for_users_at_db_level do
    execute "
    ALTER TABLE users
                ALTER COLUMN role
                SET DEFAULT 'user';
    "
  end

  def add_not_null_constraints_on_attributes_at_db_level do
    alter table("parts") do
      modify :name, :string, null: false
      modify :reference, :string, null: false
    end

    alter table("products") do
      modify :name, :string, null: false
      modify :reference, :string, null: false
    end

    alter table("categories") do
      modify :name, :string, null: false
    end
  end

  def add_default_timestamps_at_db_level do
    alter table("contacts") do
      modify :inserted_at, :utc_datetime,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      modify :updated_at, :utc_datetime,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")
    end

    alter table("users") do
      modify :inserted_at, :utc_datetime,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      modify :updated_at, :utc_datetime,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")
    end

    alter table("profiles") do
      modify :inserted_at, :utc_datetime,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      modify :updated_at, :utc_datetime,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")
    end

    alter table("categories") do
      modify :name, :string, null: false

      modify :inserted_at, :utc_datetime,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      modify :updated_at, :utc_datetime,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")
    end

    alter table("manufacturers") do
      modify :inserted_at, :utc_datetime,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      modify :updated_at, :utc_datetime,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")
    end

    alter table("products") do
      modify :inserted_at, :utc_datetime,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      modify :updated_at, :utc_datetime,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")
    end

    alter table("parts") do
      modify :inserted_at, :utc_datetime,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      modify :updated_at, :utc_datetime,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")
    end

    alter table("ownerships") do
      modify :inserted_at, :utc_datetime,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      modify :updated_at, :utc_datetime,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")
    end

    alter table("notification_templates") do
      modify :inserted_at, :utc_datetime,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      modify :updated_at, :utc_datetime,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")
    end
  end

  def add_primary_keys_for_join_tables do
    drop constraint(
           :product_parts,
           "product_parts_part_id_fkey"
         )

    drop constraint(
           :product_parts,
           "product_parts_product_id_fkey"
         )

    drop constraint(
           :product_notification_templates,
           "product_notification_templates_product_id_fkey"
         )

    drop constraint(
           :product_notification_templates,
           "product_notification_templates_notification_template_id_fkey"
         )

    drop constraint(
           :part_notification_templates,
           "part_notification_templates_part_id_fkey"
         )

    drop_if_exists constraint(
                     :part_notification_templates,
                     "part_notification_templates_part_notification_template_id_fke"
                   )

    drop_if_exists constraint(
                     :part_notification_templates,
                     "part_notification_templates_part_notification_template_id_fkey"
                   )

    drop_if_exists constraint(
                     :part_notification_templates,
                     "part_notification_templates_notification_template_id_fkey"
                   )

    drop constraint(
           :category_notification_templates,
           "category_notification_templates_category_id_fkey"
         )

    drop constraint(
           :category_notification_templates,
           "category_notification_templates_notification_template_id_fkey"
         )

    alter table("product_parts") do
      modify :product_id,
             references(:products,
               column: :id,
               name: "product_parts_product_id_fkey",
               type: :uuid,
               prefix: "public",
               on_delete: :delete_all
             ),
             primary_key: true,
             null: false

      modify :part_id,
             references(:parts,
               column: :id,
               name: "product_parts_part_id_fkey",
               type: :uuid,
               prefix: "public",
               on_delete: :delete_all
             ),
             primary_key: true,
             null: false
    end

    alter table("product_notification_templates") do
      modify :product_id,
             references(:products,
               column: :id,
               name: "product_notification_templates_product_id_fkey",
               type: :uuid,
               prefix: "public",
               on_delete: :delete_all
             ),
             primary_key: true,
             null: false

      modify :notification_template_id,
             references(:notification_templates,
               column: :id,
               name:
                 "product_notification_templates_notification_template_id_fkey",
               type: :uuid,
               prefix: "public",
               on_delete: :delete_all
             ),
             primary_key: true,
             null: false
    end

    alter table("part_notification_templates") do
      modify :part_id,
             references(:parts,
               column: :id,
               name: "part_notification_templates_part_id_fkey",
               type: :uuid,
               prefix: "public",
               on_delete: :delete_all
             ),
             primary_key: true,
             null: false

      modify :notification_template_id,
             references(:notification_templates,
               column: :id,
               name:
                 "part_notification_templates_notification_template_id_fkey",
               type: :uuid,
               prefix: "public",
               on_delete: :delete_all
             ),
             primary_key: true,
             null: false
    end

    alter table("category_notification_templates") do
      modify :category_id,
             references(:categories,
               column: :id,
               name: "category_notification_templates_category_id_fkey",
               type: :uuid,
               prefix: "public",
               on_delete: :delete_all
             ),
             primary_key: true,
             null: false

      modify :notification_template_id,
             references(:notification_templates,
               column: :id,
               name:
                 "category_notification_templates_notification_template_id_fkey",
               type: :uuid,
               prefix: "public",
               on_delete: :delete_all
             ),
             primary_key: true,
             null: false
    end

    execute "
    DROP INDEX IF EXISTS product_parts_product_id_part_id_index;
    "

    execute "
    DROP INDEX IF EXISTS product_parts_part_id_product_id_index;
    "

    execute "
    DROP INDEX IF EXISTS product_notification_templates_product_id_notification_templa;
    "

    execute "
    DROP INDEX IF EXISTS product_notification_templates_product_id_notification_template;
    "

    execute "
    DROP INDEX IF EXISTS part_notification_templates_part_id_notification_template_uui;
    "

    execute "
    DROP INDEX IF EXISTS part_notification_templates_part_id_notification_template_id_in;
    "

    execute "
    DROP INDEX IF EXISTS category_notification_templates_category_id_notification_temp;
    "

    execute "
    DROP INDEX IF EXISTS category_notification_templates_category_id_notification_templa;
    "
  end

  # -------------------------------------------------------------------------- #
  #                          MIGRATION DOWN FUNCTIONS                          #
  # -------------------------------------------------------------------------- #

  def remove_new_default_role_for_users do
    execute "
    ALTER TABLE ONLY public.users
                ALTER COLUMN role
                SET DEFAULT NULL::character varying;
    "
  end

  def remove_new_not_null_constraints_on_attributes_at_db_level do
    alter table("categories") do
      modify :name, :string, null: true
    end

    alter table("products") do
      modify :name, :string, null: true
      modify :reference, :string, null: true
    end

    alter table("parts") do
      modify :name, :string, null: true
      modify :reference, :string, null: true
    end
  end

  def remove_default_timestamps_at_db_level do
    execute "
    ALTER TABLE contacts
    ALTER COLUMN updated_at
    DROP DEFAULT;"

    execute "
    ALTER TABLE contacts
    ALTER COLUMN inserted_at
    DROP DEFAULT;"

    execute "
    ALTER TABLE users
    ALTER COLUMN updated_at
    DROP DEFAULT;"

    execute "
    ALTER TABLE users
    ALTER COLUMN inserted_at
    DROP DEFAULT;"

    execute "
    ALTER TABLE profiles
    ALTER COLUMN updated_at
    DROP DEFAULT;"

    execute "
    ALTER TABLE profiles
    ALTER COLUMN inserted_at
    DROP DEFAULT;"

    execute "
    ALTER TABLE categories
    ALTER COLUMN updated_at
    DROP DEFAULT;"

    execute "
    ALTER TABLE categories
    ALTER COLUMN inserted_at
    DROP DEFAULT;"

    execute "
    ALTER TABLE manufacturers
    ALTER COLUMN updated_at
    DROP DEFAULT;"

    execute "
    ALTER TABLE manufacturers
    ALTER COLUMN inserted_at
    DROP DEFAULT;"

    execute "
    ALTER TABLE products
    ALTER COLUMN updated_at
    DROP DEFAULT;"

    execute "
    ALTER TABLE products
    ALTER COLUMN inserted_at
    DROP DEFAULT;"

    execute "
    ALTER TABLE parts
    ALTER COLUMN updated_at
    DROP DEFAULT;"

    execute "
    ALTER TABLE parts
    ALTER COLUMN inserted_at
    DROP DEFAULT;"

    execute "
    ALTER TABLE ownerships
    ALTER COLUMN updated_at
    DROP DEFAULT;"

    execute "
    ALTER TABLE ownerships
    ALTER COLUMN inserted_at
    DROP DEFAULT;"

    execute "
    ALTER TABLE notification_templates
    ALTER COLUMN updated_at
    DROP DEFAULT;"

    execute "
    ALTER TABLE notification_templates
    ALTER COLUMN inserted_at
    DROP DEFAULT;"
  end

  def remove_primary_keys_for_join_tables do
    create unique_index(:product_parts, [:product_id, :part_id])

    create unique_index(:category_notification_templates, [
             :category_id,
             :notification_template_id
           ])

    create unique_index(:part_notification_templates, [
             :part_id,
             :notification_template_id
           ])

    create unique_index(:product_notification_templates, [
             :product_id,
             :notification_template_id
           ])

    execute "
    ALTER TABLE product_parts
    DROP CONSTRAINT product_parts_pkey;
    "

    execute "
    ALTER TABLE product_notification_templates
    DROP CONSTRAINT product_notification_templates_pkey;
    "

    execute "
    ALTER TABLE part_notification_templates
    DROP CONSTRAINT part_notification_templates_pkey;
    "

    execute "
    ALTER TABLE category_notification_templates
    DROP CONSTRAINT category_notification_templates_pkey;
    "

    alter table("category_notification_templates") do
      modify :category_id, :uuid, null: true
      modify :notification_template_id, :uuid, null: true
    end

    alter table("part_notification_templates") do
      modify :part_id, :uuid, null: true
      modify :notification_template_id, :uuid, null: true
    end

    alter table("product_notification_templates") do
      modify :product_id, :uuid, null: true
      modify :notification_template_id, :uuid, null: true
    end

    alter table("product_parts") do
      modify :product_id, :uuid, null: true
      modify :part_id, :uuid, null: true
    end
  end
end
