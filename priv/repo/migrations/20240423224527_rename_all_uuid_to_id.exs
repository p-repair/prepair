defmodule Prepair.Repo.Migrations.RenameAllUUIDsToIDs do
  use Ecto.Migration

  def up do
    replace_uuid_to_id_in_columns_names()
    replace_uuid_to_id_in_indexes_names()
    replace_uuid_to_id_in_constraints_names()
  end

  def down do
    replace_id_to_uuid_in_columns_names()
    replace_id_to_uuid_in_indexes_names()
    replace_id_to_uuid_in_constraints_names()
  end

  #########################################################
  #########################################################
  ################ MIGRATION UP FUNCTIONS #################
  #########################################################
  #########################################################

  def replace_uuid_to_id_in_columns_names do
    execute "DO $$
          DECLARE
            replace_uuid_to_id_in_columns_names TEXT;
          BEGIN
            FOR replace_uuid_to_id_in_columns_names IN
              SELECT
                'ALTER TABLE ' || tab_name || ' RENAME COLUMN '
                || quote_ident(column_name) || ' TO '
                || quote_ident( REPLACE(column_name, 'uuid', 'id')) || ';' as alter_query
              FROM (
                SELECT
                  quote_ident(table_schema) || '.' || quote_ident(table_name) as tab_name,
                  column_name
                FROM information_schema.columns
                WHERE
                  table_schema = 'public'
                  AND column_name LIKE '%uuid'
              ) sub
            LOOP
              EXECUTE replace_uuid_to_id_in_columns_names;
            END LOOP;
          END $$;"
  end

  def replace_uuid_to_id_in_indexes_names do
    execute "DO $$
            DECLARE
              replace_uuid_to_id_in_indexes_names TEXT;
            BEGIN
              FOR replace_uuid_to_id_in_indexes_names IN
    	          SELECT
    		          'ALTER INDEX ' || quote_ident(schemaname) || '.' || quote_ident(indexname)
    		          || ' RENAME TO '
    		          || quote_ident(REPLACE(indexname, 'uuid', 'id')) || ';'
		            FROM pg_indexes
		            WHERE
    		          schemaname = 'public'
    		          AND indexname LIKE '%uuid%'
              LOOP
    	          EXECUTE replace_uuid_to_id_in_indexes_names;
              END LOOP;
            END $$;"
  end

  def replace_uuid_to_id_in_constraints_names do
    execute "DO $$
            DECLARE
              replace_uuid_to_id_in_constraints_names TEXT;
            BEGIN
              FOR replace_uuid_to_id_in_constraints_names IN
                SELECT
    		          'ALTER TABLE ' || quote_ident(table_schema) || '.' || quote_ident(table_name)
    		          || ' RENAME CONSTRAINT '
    		          || quote_ident(constraint_name)
    		          || ' TO '
    		          || quote_ident(REPLACE(constraint_name, 'uuid', 'id')) || ';'
		            FROM (
    		          SELECT
        		        table_schema,
        		        table_name,
        		        constraint_name
    		          FROM information_schema.table_constraints
    		          WHERE
        		        constraint_type = 'FOREIGN KEY'
        		        AND table_schema = 'public'
        		        AND constraint_name LIKE '%uuid%'
		            ) sub
              LOOP
                EXECUTE replace_uuid_to_id_in_constraints_names;
              END LOOP;
            END $$;"
  end

  #########################################################
  #########################################################
  ############### MIGRATION DOWN FUNCTIONS ################
  #########################################################
  #########################################################

  def replace_id_to_uuid_in_columns_names do
    execute "DO $$
          DECLARE
            replace_id_to_uuid_in_columns_names TEXT;
          BEGIN
            FOR replace_id_to_uuid_in_columns_names IN
              SELECT
                'ALTER TABLE ' || tab_name || ' RENAME COLUMN '
                || quote_ident(column_name) || ' TO '
                || quote_ident( REPLACE(column_name, 'id', 'uuid')) || ';' as alter_query
              FROM (
                SELECT
                  quote_ident(table_schema) || '.' || quote_ident(table_name) as tab_name,
                  column_name
                FROM information_schema.columns
                WHERE
                  table_schema = 'public'
                  AND column_name LIKE '%id'
              ) sub
            LOOP
              EXECUTE replace_id_to_uuid_in_columns_names;
            END LOOP;
          END $$;"
  end

  def replace_id_to_uuid_in_indexes_names do
    execute "DO $$
            DECLARE
              replace_id_to_uuid_in_indexes_names TEXT;
            BEGIN
              FOR replace_id_to_uuid_in_indexes_names IN
    	          SELECT
    		          'ALTER INDEX ' || quote_ident(schemaname) || '.' || quote_ident(indexname)
    		          || ' RENAME TO '
    		          || quote_ident(REPLACE(indexname, 'id', 'uuid')) || ';'
		            FROM pg_indexes
		            WHERE
    		          schemaname = 'public'
    		          AND indexname LIKE '%id%'
              LOOP
    	          EXECUTE replace_id_to_uuid_in_indexes_names;
              END LOOP;
            END $$;"
  end

  def replace_id_to_uuid_in_constraints_names do
    execute "DO $$
            DECLARE
              replace_id_to_uuid_in_constraints_names TEXT;
            BEGIN
              FOR replace_id_to_uuid_in_constraints_names IN
                SELECT
    		          'ALTER TABLE ' || quote_ident(table_schema) || '.' || quote_ident(table_name)
    		          || ' RENAME CONSTRAINT '
    		          || quote_ident(constraint_name)
    		          || ' TO '
    		          || quote_ident(REPLACE(constraint_name, 'id', 'uuid')) || ';'
		            FROM (
    		          SELECT
        		        table_schema,
        		        table_name,
        		        constraint_name
    		          FROM information_schema.table_constraints
    		          WHERE
        		        constraint_type = 'FOREIGN KEY'
        		        AND table_schema = 'public'
        		        AND constraint_name LIKE '%id%'
		            ) sub
              LOOP
                EXECUTE replace_id_to_uuid_in_constraints_names;
              END LOOP;
            END $$;"
  end
end
