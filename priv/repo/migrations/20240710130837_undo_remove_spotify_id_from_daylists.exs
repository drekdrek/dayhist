defmodule Dayhist.Repo.Migrations.UndoRemoveSpotifyIdFromDaylists do
  use Ecto.Migration

  def change do
    alter table(:daylists) do
      add :spotify_playlist_id, :string
    end
  end
end
