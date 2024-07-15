defmodule Dayhist.Repo.Migrations.AddJsonIndexToDaylist do
  use Ecto.Migration

  def up do
    execute """
      CREATE INDEX daylist_contents ON daylists USING GIN(contents)
    """
  end
end
