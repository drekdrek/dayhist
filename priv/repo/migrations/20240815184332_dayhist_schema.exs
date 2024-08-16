defmodule Dayhist.Repo.Migrations.DayhistSchema do
  use Ecto.Migration

  @schema_prefix "dayhist"

  def up do
    execute("CREATE SCHEMA #{@schema_prefix}")
  end

  def down do
    execute("DROP SCHEMA #{@schema_prefix}")
  end
end
