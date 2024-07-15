defmodule Dayhist.Repo.Migrations.AddPlaylistContentsAndDateToDaylist do
  use Ecto.Migration

  def change do
    alter table(:daylists) do
      remove :name
      add :contents, :map
    end
  end


end
