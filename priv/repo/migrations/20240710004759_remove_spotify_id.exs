defmodule Dayhist.Repo.Migrations.RemoveSpotifyId do
  use Ecto.Migration

  def change do
    alter table(:daylists) do
      remove :spotify_playlist_id
    end
  end
end
