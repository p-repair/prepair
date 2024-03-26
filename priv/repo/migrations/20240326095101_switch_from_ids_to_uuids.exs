defmodule Prepair.Repo.Migrations.SwitchFromIDsToUUIDs do
  use Ecto.Migration

  def up do
    create_uuid_keys()
    create_unique_uuid_indexes()
    populate_all_uuid_fields()
    set_uuid_as_primary_keys()
    remove_useless_uuid_indexes()
    add_uuid_relations()
    create_uuid_relation_indexes()
  end

  def down do
    create_id_keys()
    create_unique_id_indexes()
    populate_all_id_field()
    set_id_as_primary_keys()
    remove_useless_id_indexes()
    add_id_relations()
    create_id_relation_indexes()
  end

  #########################################################
  #########################################################
  ################ MIGRATION UP FUNCTIONS #################
  #########################################################
  #########################################################

  # Add a UUID fields on each table + anticipate relations.
  def create_uuid_keys() do
    # Users
    alter table(:users) do
      add :uuid, :uuid, null: false, default: fragment("gen_random_uuid()")
    end

    # Profiles
    alter table(:profiles) do
      add :uuid, :uuid
    end

    # Users tokens
    alter table(:users_tokens) do
      add :uuid, :uuid, null: false, default: fragment("gen_random_uuid()")
      add :user_uuid, :uuid
    end

    # Api keys
    alter table(:api_keys) do
      add :uuid, :uuid, null: false, default: fragment("gen_random_uuid()")
    end

    # Contacts
    alter table(:contacts) do
      add :uuid, :uuid, null: false, default: fragment("gen_random_uuid()")
    end

    # Categories
    alter table(:categories) do
      add :uuid, :uuid, null: false, default: fragment("gen_random_uuid()")
    end

    # Manufacturers
    alter table(:manufacturers) do
      add :uuid, :uuid, null: false, default: fragment("gen_random_uuid()")
    end

    # Products
    alter table(:products) do
      add :uuid, :uuid, null: false, default: fragment("gen_random_uuid()")
      add :category_uuid, :uuid
      add :manufacturer_uuid, :uuid
    end

    # Parts
    alter table(:parts) do
      add :uuid, :uuid, null: false, default: fragment("gen_random_uuid()")
      add :category_uuid, :uuid
      add :manufacturer_uuid, :uuid
    end

    # Product parts
    alter table(:product_parts) do
      add :product_uuid, :uuid
      add :part_uuid, :uuid
    end

    # Notification templates
    alter table(:notification_templates) do
      add :uuid, :uuid, null: false, default: fragment("gen_random_uuid()")
    end

    # Category notification templates
    alter table(:category_notification_templates) do
      add :category_uuid, :uuid
      add :notification_template_uuid, :uuid
    end

    # Product notification templates
    alter table(:product_notification_templates) do
      add :product_uuid, :uuid
      add :notification_template_uuid, :uuid
    end

    # Part notification templates
    alter table(:part_notification_templates) do
      add :part_uuid, :uuid
      add :notification_template_uuid, :uuid
    end

    # Ownerships
    alter table(:ownerships) do
      add :uuid, :uuid, null: false, default: fragment("gen_random_uuid()")
      add :profile_uuid, :uuid
      add :product_uuid, :uuid
    end
  end

  # Create unique indexes for all tables except join tables.
  def create_unique_uuid_indexes() do
    create unique_index(:users, [:uuid])
    create unique_index(:profiles, [:uuid])
    create unique_index(:users_tokens, [:uuid])
    create unique_index(:api_keys, [:uuid])
    create unique_index(:contacts, [:uuid])
    create unique_index(:categories, [:uuid])
    create unique_index(:manufacturers, [:uuid])
    create unique_index(:products, [:uuid])
    create unique_index(:parts, [:uuid])
    create unique_index(:notification_templates, [:uuid])
    create unique_index(:ownerships, [:uuid])
  end

  def populate_all_uuid_fields do
    ## Profiles
    execute "UPDATE profiles
          SET uuid = users.uuid
          FROM users
          WHERE profiles.id = users.id;"

    alter table(:profiles) do
      modify :uuid, :uuid, null: false
    end

    ## Users tokens
    execute "UPDATE users_tokens
          SET user_uuid = users.uuid
          FROM users
          WHERE users_tokens.user_id = users.id;"

    ## Products
    execute "UPDATE products
          SET category_uuid = categories.uuid
          FROM categories
          WHERE products.category_id = categories.id;"

    execute "UPDATE products
          SET manufacturer_uuid = manufacturers.uuid
          FROM manufacturers
          WHERE products.manufacturer_id = manufacturers.id;"

    ## Parts
    execute "UPDATE parts
          SET category_uuid = categories.uuid
          FROM categories
          WHERE parts.category_id = categories.id;"

    execute "UPDATE parts
          SET manufacturer_uuid = manufacturers.uuid
          FROM manufacturers
          WHERE parts.manufacturer_id = manufacturers.id;"

    ## Product parts
    execute "UPDATE product_parts
          SET product_uuid = products.uuid
          FROM products
          WHERE product_parts.product_id = products.id;"

    execute "UPDATE product_parts
          SET part_uuid = parts.uuid
          FROM parts
          WHERE product_parts.part_id = parts.id;"

    ## Category notification templates
    execute "UPDATE category_notification_templates
          SET category_uuid = categories.uuid
          FROM categories
          WHERE category_notification_templates.category_id = categories.id;"

    execute "UPDATE category_notification_templates
          SET notification_template_uuid = notification_templates.uuid
          FROM notification_templates
          WHERE category_notification_templates.notification_template_id =
            notification_templates.id;"

    ## Product notification templates
    execute "UPDATE product_notification_templates
          SET product_uuid = products.uuid
          FROM products
          WHERE product_notification_templates.product_id = products.id;"

    execute "UPDATE product_notification_templates
          SET notification_template_uuid = notification_templates.uuid
          FROM notification_templates
          WHERE product_notification_templates.notification_template_id =
            notification_templates.id;"

    ## Part notification templates
    execute "UPDATE part_notification_templates
          SET part_uuid = parts.uuid
          FROM parts
          WHERE part_notification_templates.part_id = parts.id;"

    execute "UPDATE part_notification_templates
          SET notification_template_uuid = notification_templates.uuid
          FROM notification_templates
          WHERE part_notification_templates.notification_template_id =
            notification_templates.id;"

    ## Ownerships
    execute "UPDATE ownerships
          SET profile_uuid = profiles.uuid
          FROM profiles
          WHERE ownerships.profile_id = profiles.id;"

    execute "UPDATE ownerships
          SET product_uuid = products.uuid
          FROM products
          WHERE ownerships.product_id = products.id;"
  end

  def set_uuid_as_primary_keys do
    ## Users
    execute "ALTER TABLE users DROP CONSTRAINT users_pkey CASCADE;"
    execute "ALTER TABLE users ADD PRIMARY KEY (uuid);"
    execute "ALTER TABLE users DROP COLUMN id;"

    ## Profiles
    execute "ALTER TABLE profiles DROP CONSTRAINT profiles_pkey CASCADE;"
    execute "ALTER TABLE profiles ADD PRIMARY KEY (uuid);"
    execute "ALTER TABLE profiles DROP COLUMN id;"

    ## Users tokens
    execute "ALTER TABLE users_tokens DROP CONSTRAINT users_tokens_pkey CASCADE;"
    execute "ALTER TABLE users_tokens ADD PRIMARY KEY (uuid);"
    execute "ALTER TABLE users_tokens DROP COLUMN id;"
    execute "ALTER TABLE users_tokens DROP COLUMN user_id;"

    ## Api keys
    execute "ALTER TABLE api_keys DROP CONSTRAINT api_keys_pkey CASCADE;"
    execute "ALTER TABLE api_keys ADD PRIMARY KEY (uuid);"
    execute "ALTER TABLE api_keys DROP COLUMN id;"

    ## Contacts
    execute "ALTER TABLE contacts DROP CONSTRAINT contacts_pkey CASCADE;"
    execute "ALTER TABLE contacts ADD PRIMARY KEY (uuid);"
    execute "ALTER TABLE contacts DROP COLUMN id;"

    ## Categories
    execute "ALTER TABLE categories DROP CONSTRAINT categories_pkey CASCADE;"
    execute "ALTER TABLE categories ADD PRIMARY KEY (uuid);"
    execute "ALTER TABLE categories DROP COLUMN id;"

    ## Manufacturers
    execute "ALTER TABLE manufacturers DROP CONSTRAINT manufacturers_pkey CASCADE;"
    execute "ALTER TABLE manufacturers ADD PRIMARY KEY (uuid);"
    execute "ALTER TABLE manufacturers DROP COLUMN id;"

    ## Products
    execute "ALTER TABLE products DROP CONSTRAINT products_pkey CASCADE;"
    execute "ALTER TABLE products ADD PRIMARY KEY (uuid);"
    execute "ALTER TABLE products DROP COLUMN id;"
    execute "ALTER TABLE products DROP COLUMN category_id;"
    execute "ALTER TABLE products DROP COLUMN manufacturer_id;"

    ## Parts
    execute "ALTER TABLE parts DROP CONSTRAINT parts_pkey CASCADE;"
    execute "ALTER TABLE parts ADD PRIMARY KEY (uuid);"
    execute "ALTER TABLE parts DROP COLUMN id;"
    execute "ALTER TABLE parts DROP COLUMN category_id;"
    execute "ALTER TABLE parts DROP COLUMN manufacturer_id;"

    ## Product parts
    execute "ALTER TABLE product_parts DROP COLUMN product_id;"
    execute "ALTER TABLE product_parts DROP COLUMN part_id;"

    ## Notification templates
    execute "ALTER TABLE notification_templates
      DROP CONSTRAINT notification_templates_pkey CASCADE;"
    execute "ALTER TABLE notification_templates
      ADD PRIMARY KEY (uuid);"
    execute "ALTER TABLE notification_templates DROP COLUMN id;"

    ## Category notification templates
    execute "ALTER TABLE category_notification_templates
          DROP COLUMN category_id;"
    execute "ALTER TABLE category_notification_templates
          DROP COLUMN notification_template_id;"

    ## Product notification templates
    execute "ALTER TABLE product_notification_templates
          DROP COLUMN product_id;"
    execute "ALTER TABLE product_notification_templates
          DROP COLUMN notification_template_id;"

    ## Part notification templates
    execute "ALTER TABLE part_notification_templates
           DROP COLUMN part_id;"
    execute "ALTER TABLE part_notification_templates
          DROP COLUMN notification_template_id;"

    ## Ownerships
    execute "ALTER TABLE ownerships DROP CONSTRAINT ownerships_pkey CASCADE;"
    execute "ALTER TABLE ownerships ADD PRIMARY KEY (uuid);"
    execute "ALTER TABLE ownerships DROP COLUMN id;"
    execute "ALTER TABLE ownerships DROP COLUMN profile_id;"
    execute "ALTER TABLE ownerships DROP COLUMN product_id;"
  end

  def add_uuid_relations() do
    ## Users + profiles
    execute "ALTER TABLE users
          ADD CONSTRAINT users_uuid_fkey
          FOREIGN KEY (uuid)
          REFERENCES profiles (uuid)
          ON DELETE CASCADE
          DEFERRABLE INITIALLY DEFERRED;"

    execute "ALTER TABLE profiles
          ADD CONSTRAINT profiles_uuid_fkey
          FOREIGN KEY (uuid)
          REFERENCES users (uuid)
          ON DELETE CASCADE;"

    ## Users tokens
    execute "ALTER TABLE users_tokens
          ADD CONSTRAINT users_tokens_user_uuid_fkey
          FOREIGN KEY (user_uuid)
          REFERENCES users (uuid)
          ON DELETE CASCADE;"

    ## Products
    execute "ALTER TABLE products
          ADD CONSTRAINT products_category_uuid_fkey
          FOREIGN KEY (category_uuid)
          REFERENCES categories (uuid)
          ON DELETE CASCADE;"

    execute "ALTER TABLE products
          ADD CONSTRAINT products_manufacturer_uuid_fkey
          FOREIGN KEY (manufacturer_uuid)
          REFERENCES manufacturers (uuid)
          ON DELETE CASCADE;"

    ## Parts
    execute "ALTER TABLE parts
          ADD CONSTRAINT parts_category_uuid_fkey
          FOREIGN KEY (category_uuid)
          REFERENCES categories (uuid)
          ON DELETE CASCADE;"

    execute "ALTER TABLE parts
          ADD CONSTRAINT parts_manufacturer_uuid_fkey
          FOREIGN KEY (manufacturer_uuid)
          REFERENCES manufacturers (uuid)
          ON DELETE CASCADE;"

    ## Product parts
    execute "ALTER TABLE product_parts
          ADD CONSTRAINT product_parts_product_uuid_fkey
          FOREIGN KEY (product_uuid)
          REFERENCES products (uuid)
          ON DELETE CASCADE;"

    execute "ALTER TABLE product_parts
          ADD CONSTRAINT product_parts_part_uuid_fkey
          FOREIGN KEY (part_uuid)
          REFERENCES parts (uuid)
          ON DELETE CASCADE;"

    ## Category notification templates
    execute "ALTER TABLE category_notification_templates
          ADD CONSTRAINT category_notification_templates_category_uuid_fkey
          FOREIGN KEY (category_uuid)
          REFERENCES categories (uuid)
          ON DELETE CASCADE;"

    execute "ALTER TABLE category_notification_templates
          ADD CONSTRAINT category_notification_templates_notification_template_uuid_fkey
          FOREIGN KEY (notification_template_uuid)
          REFERENCES notification_templates (uuid)
          ON DELETE CASCADE;"

    ## Product notification templates
    execute "ALTER TABLE product_notification_templates
          ADD CONSTRAINT product_notification_templates_product_uuid_fkey
          FOREIGN KEY (product_uuid)
          REFERENCES products (uuid)
          ON DELETE CASCADE;"

    execute "ALTER TABLE product_notification_templates
          ADD CONSTRAINT product_notification_templates_notification_template_uuid_fkey
          FOREIGN KEY (notification_template_uuid)
          REFERENCES notification_templates (uuid)
          ON DELETE CASCADE;"

    ## Part notification templates
    execute "ALTER TABLE part_notification_templates
          ADD CONSTRAINT part_notification_templates_notification_template_uuid_fkey
          FOREIGN KEY (part_uuid)
          REFERENCES parts (uuid)
          ON DELETE CASCADE;"

    execute "ALTER TABLE part_notification_templates
          ADD CONSTRAINT part_notification_templates_part_uuid_fkey
          FOREIGN KEY (notification_template_uuid)
          REFERENCES notification_templates (uuid)
          ON DELETE CASCADE;"

    ## Ownerships
    execute "ALTER TABLE ownerships
          ADD CONSTRAINT ownerships_product_uuid_fkey
          FOREIGN KEY (product_uuid)
          REFERENCES products (uuid)
          ON DELETE CASCADE;"

    execute "ALTER TABLE ownerships
          ADD CONSTRAINT ownerships_profile_uuid_fkey
          FOREIGN KEY (profile_uuid)
          REFERENCES profiles (uuid)
          ON DELETE CASCADE;"
  end

  def create_uuid_relation_indexes() do
    # Products
    create unique_index(:products, [:reference, :manufacturer_uuid])
    create index(:products, [:manufacturer_uuid])
    create index(:products, [:category_uuid])

    # Parts
    create unique_index(:parts, [:reference, :manufacturer_uuid])

    # Product parts
    create unique_index(:product_parts, [:product_uuid, :part_uuid])
    create index(:product_parts, [:product_uuid])
    create index(:product_parts, [:part_uuid])

    # Category notification templates
    create unique_index(:category_notification_templates, [
             :category_uuid,
             :notification_template_uuid
           ])

    create index(:category_notification_templates, [:category_uuid])

    create index(:category_notification_templates, [:notification_template_uuid])

    # Product notification templates
    create unique_index(:product_notification_templates, [
             :product_uuid,
             :notification_template_uuid
           ])

    create index(:product_notification_templates, [:product_uuid])
    create index(:product_notification_templates, [:notification_template_uuid])

    # Part notification templates
    create unique_index(:part_notification_templates, [
             :part_uuid,
             :notification_template_uuid
           ])

    create index(:part_notification_templates, [:part_uuid])
    create index(:part_notification_templates, [:notification_template_uuid])

    # Ownerships
    create index(:ownerships, [:product_uuid])
    create index(:ownerships, [:profile_uuid])
  end

  def remove_useless_uuid_indexes() do
    ## Users
    execute "DROP INDEX users_uuid_index CASCADE;"

    ## Profiles
    execute "DROP INDEX profiles_uuid_index CASCADE;"

    ## Users tokens
    execute "DROP INDEX users_tokens_uuid_index CASCADE;"

    ## Api keys
    execute "DROP INDEX api_keys_uuid_index CASCADE;"

    ## Contacts
    execute "DROP INDEX contacts_uuid_index CASCADE;"

    ## Categories
    execute "DROP INDEX categories_uuid_index CASCADE;"

    ## Manufacturers
    execute "DROP INDEX manufacturers_uuid_index CASCADE;"

    ## Products
    execute "DROP INDEX products_uuid_index CASCADE;"

    ## Parts
    execute "DROP INDEX parts_uuid_index CASCADE;"

    ## Notification templates
    execute "DROP INDEX notification_templates_uuid_index CASCADE;"

    ## Ownerships
    execute "DROP INDEX ownerships_uuid_index CASCADE;"
  end

  #########################################################
  #########################################################
  ############### MIGRATION DOWN FUNCTIONS ################
  #########################################################
  #########################################################

  def create_id_keys() do
    ## Users + profiles
    execute "ALTER TABLE users ADD COLUMN id BIGSERIAL;"
    execute "ALTER TABLE profiles ADD COLUMN id bigint;"

    ## Users tokens
    execute "ALTER TABLE users_tokens ADD COLUMN id BIGSERIAL;"
    execute "ALTER TABLE users_tokens ADD COLUMN user_id bigint;"

    ## Api keys
    execute "ALTER TABLE api_keys ADD COLUMN id BIGSERIAL;"

    ## Contacts
    execute "ALTER TABLE contacts ADD COLUMN id BIGSERIAL;"

    ## Categories
    execute "ALTER TABLE categories ADD COLUMN id BIGSERIAL;"

    ## Manufacturers
    execute "ALTER TABLE manufacturers ADD COLUMN id BIGSERIAL;"

    ## Products
    execute "ALTER TABLE products ADD COLUMN id BIGSERIAL;"
    execute "ALTER TABLE products ADD COLUMN category_id bigint;"
    execute "ALTER TABLE products ADD COLUMN manufacturer_id bigint;"

    ## Parts
    execute "ALTER TABLE parts ADD COLUMN id BIGSERIAL;"
    execute "ALTER TABLE parts ADD COLUMN category_id bigint;"
    execute "ALTER TABLE parts ADD COLUMN manufacturer_id bigint;"

    ## Product parts
    execute "ALTER TABLE product_parts
          ADD COLUMN product_id bigint;"
    execute "ALTER TABLE product_parts
          ADD COLUMN part_id bigint;"

    ## Category notification templates
    execute "ALTER TABLE category_notification_templates
          ADD COLUMN category_id bigint;"
    execute "ALTER TABLE category_notification_templates
          ADD COLUMN notification_template_id bigint;"

    ## Product notification templates
    execute "ALTER TABLE product_notification_templates
          ADD COLUMN product_id bigint;"
    execute "ALTER TABLE product_notification_templates
          ADD COLUMN notification_template_id bigint;"

    ## Part notification templates
    execute "ALTER TABLE part_notification_templates
          ADD COLUMN part_id bigint;"
    execute "ALTER TABLE part_notification_templates
          ADD COLUMN notification_template_id bigint;"

    ## Notification templates
    execute "ALTER TABLE notification_templates ADD COLUMN id BIGSERIAL;"

    ## Ownerships
    execute "ALTER TABLE ownerships ADD COLUMN id BIGSERIAL;"
    execute "ALTER TABLE ownerships
          ADD COLUMN profile_id bigint;"
    execute "ALTER TABLE ownerships
          ADD COLUMN product_id bigint;"
  end

  # Create unique indexes for all tables except join tables.
  def create_unique_id_indexes() do
    create unique_index(:users, [:id])
    create unique_index(:profiles, [:id])
    create unique_index(:users_tokens, [:id])
    create unique_index(:api_keys, [:id])
    create unique_index(:contacts, [:id])
    create unique_index(:categories, [:id])
    create unique_index(:manufacturers, [:id])
    create unique_index(:products, [:id])
    create unique_index(:parts, [:id])
    create unique_index(:notification_templates, [:id])
    create unique_index(:ownerships, [:id])
  end

  def populate_all_id_field() do
    ## Users + profiles
    execute "UPDATE profiles
          SET id = users.id
          FROM users
          WHERE profiles.uuid = users.uuid;"

    execute "CREATE SEQUENCE profiles_id_seq;"

    execute "ALTER TABLE profiles
          ALTER COLUMN id TYPE bigint,
          ALTER COLUMN id SET NOT NULL,
          ALTER COLUMN id SET NOT NULL,
          ALTER COLUMN id SET DEFAULT nextval('profiles_id_seq');"

    execute "ALTER SEQUENCE profiles_id_seq
          OWNED BY profiles.id;"

    ## Users tokens
    execute "UPDATE users_tokens
          SET user_id = users.id
          FROM users
          WHERE users_tokens.uuid = users.uuid;"

    ## Products
    execute "UPDATE products
          SET category_id = categories.id
          FROM categories
          WHERE products.category_uuid = categories.uuid;"

    execute "UPDATE products
          SET manufacturer_id = manufacturers.id
          FROM manufacturers
          WHERE products.manufacturer_uuid = manufacturers.uuid;"

    ## Parts
    execute "UPDATE parts
          SET category_id = categories.id
          FROM categories
          WHERE parts.category_uuid = categories.uuid;"

    execute "UPDATE parts
          SET manufacturer_id = manufacturers.id
          FROM manufacturers
          WHERE parts.manufacturer_uuid = manufacturers.uuid;"

    ## Product parts
    execute "UPDATE product_parts
          SET product_id = products.id
          FROM products
          WHERE product_parts.product_uuid = products.uuid;"

    execute "UPDATE product_parts
          SET part_id = parts.id
          FROM parts
          WHERE product_parts.part_uuid = parts.uuid;"

    ## Category notification templates
    execute "UPDATE category_notification_templates
          SET category_id = categories.id
          FROM categories
          WHERE category_notification_templates.category_uuid =
            categories.uuid;"

    execute "UPDATE category_notification_templates
          SET notification_template_id = notification_templates.id
          FROM notification_templates
          WHERE category_notification_templates.notification_template_uuid =
            notification_templates.uuid;"

    ## Product notification templates
    execute "UPDATE product_notification_templates
          SET product_id = products.id
          FROM products
          WHERE product_notification_templates.product_uuid =
            products.uuid;"

    execute "UPDATE product_notification_templates
          SET notification_template_id = notification_templates.id
          FROM notification_templates
          WHERE product_notification_templates.notification_template_uuid =
            notification_templates.uuid;"

    ## Part notification templates
    execute "UPDATE part_notification_templates
          SET part_id = parts.id
          FROM parts
          WHERE part_notification_templates.part_uuid = parts.uuid;"

    execute "UPDATE part_notification_templates
          SET notification_template_id = notification_templates.id
          FROM notification_templates
          WHERE part_notification_templates.notification_template_uuid =
            notification_templates.uuid;"

    ## Ownerships
    execute "UPDATE ownerships
          SET profile_id = profiles.id
          FROM profiles
          WHERE ownerships.profile_uuid = profiles.uuid;"

    execute "UPDATE ownerships
          SET product_id = products.id
          FROM products
          WHERE ownerships.product_uuid = products.uuid;"
  end

  def set_id_as_primary_keys() do
    ## Users
    execute "ALTER TABLE users DROP CONSTRAINT users_pkey CASCADE;"
    execute "ALTER TABLE users ADD PRIMARY KEY (id);"
    execute "ALTER TABLE users DROP COLUMN uuid;"

    ## Profiles
    execute "ALTER TABLE profiles DROP CONSTRAINT profiles_pkey CASCADE;"
    execute "ALTER TABLE profiles ADD PRIMARY KEY (id);"
    execute "ALTER TABLE profiles DROP COLUMN uuid;"

    ## Users tokens
    execute "ALTER TABLE users_tokens DROP CONSTRAINT users_tokens_pkey CASCADE;"
    execute "ALTER TABLE users_tokens ADD PRIMARY KEY (id);"
    execute "ALTER TABLE users_tokens DROP COLUMN uuid;"
    execute "ALTER TABLE users_tokens DROP COLUMN user_uuid;"

    ## Api keys
    execute "ALTER TABLE api_keys DROP CONSTRAINT api_keys_pkey CASCADE;"
    execute "ALTER TABLE api_keys ADD PRIMARY KEY (id);"
    execute "ALTER TABLE api_keys DROP COLUMN uuid;"

    ## Contacts
    execute "ALTER TABLE contacts DROP CONSTRAINT contacts_pkey CASCADE;"
    execute "ALTER TABLE contacts ADD PRIMARY KEY (id);"
    execute "ALTER TABLE contacts DROP COLUMN uuid;"

    ## Categories
    execute "ALTER TABLE categories DROP CONSTRAINT categories_pkey CASCADE;"
    execute "ALTER TABLE categories ADD PRIMARY KEY (id);"
    execute "ALTER TABLE categories DROP COLUMN uuid;"

    ## Manufacturers
    execute "ALTER TABLE manufacturers DROP CONSTRAINT manufacturers_pkey CASCADE;"
    execute "ALTER TABLE manufacturers ADD PRIMARY KEY (id);"
    execute "ALTER TABLE manufacturers DROP COLUMN uuid;"

    ## Products
    execute "ALTER TABLE products DROP CONSTRAINT products_pkey CASCADE;"
    execute "ALTER TABLE products ADD PRIMARY KEY (id);"
    execute "ALTER TABLE products DROP COLUMN uuid;"
    execute "ALTER TABLE products DROP COLUMN category_uuid;"
    execute "ALTER TABLE products DROP COLUMN manufacturer_uuid;"

    ## Parts
    execute "ALTER TABLE parts DROP CONSTRAINT parts_pkey CASCADE;"
    execute "ALTER TABLE parts ADD PRIMARY KEY (id);"
    execute "ALTER TABLE parts DROP COLUMN uuid;"
    execute "ALTER TABLE parts DROP COLUMN category_uuid;"
    execute "ALTER TABLE parts DROP COLUMN manufacturer_uuid;"

    ## Product parts
    execute "ALTER TABLE product_parts DROP COLUMN product_uuid;"
    execute "ALTER TABLE product_parts DROP COLUMN part_uuid;"

    ## Notification templates
    execute "ALTER TABLE notification_templates
          DROP CONSTRAINT notification_templates_pkey CASCADE;"
    execute "ALTER TABLE notification_templates ADD PRIMARY KEY (id);"
    execute "ALTER TABLE notification_templates DROP COLUMN uuid;"

    ## Category notification templates
    execute "ALTER TABLE category_notification_templates
          DROP COLUMN category_uuid;"
    execute "ALTER TABLE category_notification_templates
          DROP COLUMN notification_template_uuid;"

    ## Product notification templates
    execute "ALTER TABLE product_notification_templates
          DROP COLUMN product_uuid;"
    execute "ALTER TABLE product_notification_templates
          DROP COLUMN notification_template_uuid;"

    ## Part notification templates
    execute "ALTER TABLE part_notification_templates
           DROP COLUMN part_uuid;"
    execute "ALTER TABLE part_notification_templates
          DROP COLUMN notification_template_uuid;"

    ## Ownerships
    execute "ALTER TABLE ownerships DROP CONSTRAINT ownerships_pkey CASCADE;"
    execute "ALTER TABLE ownerships ADD PRIMARY KEY (id);"
    execute "ALTER TABLE ownerships DROP COLUMN uuid;"
    execute "ALTER TABLE ownerships DROP COLUMN profile_uuid;"
    execute "ALTER TABLE ownerships DROP COLUMN product_uuid;"
  end

  def remove_useless_id_indexes() do
    ## Users
    execute "DROP INDEX users_id_index CASCADE;"

    ## Profiles
    execute "DROP INDEX profiles_id_index CASCADE;"

    ## Users tokens
    execute "DROP INDEX users_tokens_id_index CASCADE;"

    ## Api keys
    execute "DROP INDEX api_keys_id_index CASCADE;"

    ## Contacts
    execute "DROP INDEX contacts_id_index CASCADE;"

    ## Categories
    execute "DROP INDEX categories_id_index CASCADE;"

    ## Manufacturers
    execute "DROP INDEX manufacturers_id_index CASCADE;"

    ## Products
    execute "DROP INDEX products_id_index CASCADE;"

    ## Parts
    execute "DROP INDEX parts_id_index CASCADE;"

    ## Notification templates
    execute "DROP INDEX notification_templates_id_index CASCADE;"

    ## Ownerships
    execute "DROP INDEX ownerships_id_index CASCADE;"
  end

  def add_id_relations() do
    ## Users + profiles
    execute "ALTER TABLE users
          ADD CONSTRAINT users_id_fkey
          FOREIGN KEY (id)
          REFERENCES profiles (id)
          ON DELETE CASCADE
          DEFERRABLE INITIALLY DEFERRED;"

    execute "ALTER TABLE profiles
          ADD CONSTRAINT profiles_id_fkey
          FOREIGN KEY (id)
          REFERENCES users (id)
          ON DELETE CASCADE;"

    ## Users tokens
    execute "ALTER TABLE users_tokens
          ADD CONSTRAINT users_tokens_user_id_fkey
          FOREIGN KEY (user_id)
          REFERENCES users (id)
          ON DELETE CASCADE;"

    ## Products
    execute "ALTER TABLE products
          ADD CONSTRAINT products_category_id_fkey
          FOREIGN KEY (category_id)
          REFERENCES categories (id)
          ON DELETE CASCADE;"

    execute "ALTER TABLE products
          ADD CONSTRAINT products_manufacturer_id_fkey
          FOREIGN KEY (manufacturer_id)
          REFERENCES manufacturers (id)
          ON DELETE CASCADE;"

    ## Parts
    execute "ALTER TABLE parts
          ADD CONSTRAINT parts_category_id_fkey
          FOREIGN KEY (category_id)
          REFERENCES categories (id)
          ON DELETE CASCADE;"

    execute "ALTER TABLE parts
          ADD CONSTRAINT parts_manufacturer_id_fkey
          FOREIGN KEY (manufacturer_id)
          REFERENCES manufacturers (id)
          ON DELETE CASCADE;"

    ## Product parts
    execute "ALTER TABLE product_parts
          ADD CONSTRAINT product_parts_product_uuid_fkey
          FOREIGN KEY (product_id)
          REFERENCES products (id)
          ON DELETE CASCADE;"

    execute "ALTER TABLE product_parts
          ADD CONSTRAINT product_parts_part_uuid_fkey
          FOREIGN KEY (part_id)
          REFERENCES parts (id)
          ON DELETE CASCADE;"

    ## Category notification templates
    execute "ALTER TABLE category_notification_templates
          ADD CONSTRAINT category_notification_templates_category_id_fkey
          FOREIGN KEY (category_id)
          REFERENCES categories (id)
          ON DELETE CASCADE;"

    execute "ALTER TABLE category_notification_templates
          ADD CONSTRAINT category_notification_templates_notification_template_id_fkey
          FOREIGN KEY (notification_template_id)
          REFERENCES notification_templates (id)
          ON DELETE CASCADE;"

    ## Product notification templates
    execute "ALTER TABLE product_notification_templates
          ADD CONSTRAINT product_notification_templates_product_id_fkey
          FOREIGN KEY (product_id)
          REFERENCES products (id)
          ON DELETE CASCADE;"

    execute "ALTER TABLE product_notification_templates
          ADD CONSTRAINT product_notification_templates_notification_template_id_fkey
          FOREIGN KEY (notification_template_id)
          REFERENCES notification_templates (id)
          ON DELETE CASCADE;"

    ## Part notification templates
    execute "ALTER TABLE part_notification_templates
          ADD CONSTRAINT part_notification_templates_part_id_fkey
          FOREIGN KEY (part_id)
          REFERENCES parts (id)
          ON DELETE CASCADE;"

    execute "ALTER TABLE part_notification_templates
          ADD CONSTRAINT part_notification_templates_notification_template_id_fkey
          FOREIGN KEY (notification_template_id)
          REFERENCES notification_templates (id)
          ON DELETE CASCADE;"

    ## Ownerships
    execute "ALTER TABLE ownerships
          ADD CONSTRAINT ownerships_product_id_fkey
          FOREIGN KEY (product_id)
          REFERENCES products (id)
          ON DELETE CASCADE;"

    execute "ALTER TABLE ownerships
          ADD CONSTRAINT ownerships_profile_id_fkey
          FOREIGN KEY (profile_id)
          REFERENCES profiles (id)
          ON DELETE CASCADE;"
  end

  def create_id_relation_indexes() do
    # Products
    create unique_index(:products, [:reference, :manufacturer_id])
    create index(:products, [:manufacturer_id])
    create index(:products, [:category_id])

    # Parts
    create unique_index(:parts, [:reference, :manufacturer_id])

    # Product parts
    create unique_index(:product_parts, [:product_id, :part_id])
    create index(:product_parts, [:product_id])
    create index(:product_parts, [:part_id])

    # Category notification templates
    create unique_index(:category_notification_templates, [
             :category_id,
             :notification_template_id
           ])

    create index(:category_notification_templates, [:category_id])

    create index(:category_notification_templates, [:notification_template_id])

    # Product notification templates
    create unique_index(:product_notification_templates, [
             :product_id,
             :notification_template_id
           ])

    create index(:product_notification_templates, [:product_id])
    create index(:product_notification_templates, [:notification_template_id])

    # Part notification templates
    create unique_index(:part_notification_templates, [
             :part_id,
             :notification_template_id
           ])

    create index(:part_notification_templates, [:part_id])
    create index(:part_notification_templates, [:notification_template_id])

    # Ownerships
    create index(:ownerships, [:product_id])
    create index(:ownerships, [:profile_id])
  end
end
