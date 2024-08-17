defmodule Dayhist.Repo.Migrations.RenameDayhistToMeta do
  use Ecto.Migration

  @old_prefix "dayhist"
  @new_prefix "meta"
  @table_name :user

  def up do
    # Create the new schema if it doesn't exist
    execute("CREATE SCHEMA #{@new_prefix}")

    # Move the table from old schema to new schema
    execute("ALTER TABLE #{@old_prefix}.#{@table_name} SET SCHEMA #{@new_prefix};")

    execute("DROP SCHEMA #{@old_prefix};")
  end

  def down do
    execute("CREATE SCHEMA #{@new_prefix};")

    # Move the table back to the old schema
    execute("ALTER TABLE #{@new_prefix}.#{@table_name} SET SCHEMA #{@old_prefix};")

    # Optionally, drop the new schema if empty
    execute("DROP SCHEMA #{@new_prefix};")
  end
end
