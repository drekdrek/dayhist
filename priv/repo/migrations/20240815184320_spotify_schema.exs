defmodule Dayhist.Repo.Migrations.SpotifySchema do
  use Ecto.Migration

  @schema_prefix "spotify"

  def up do
    execute("CREATE SCHEMA #{@schema_prefix}")
  end

  def down do
    execute("DROP SCHEMA #{@schema_prefix}")
  end
end
