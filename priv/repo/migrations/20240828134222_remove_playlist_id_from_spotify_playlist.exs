defmodule Dayhist.Repo.Migrations.RemovePlaylistIdFromSpotifyPlaylist do
  use Ecto.Migration

  @schema_prefix "spotify"

  def change do
    alter table(:playlist, prefix: @schema_prefix) do
      remove :playlist_id
    end
  end
end
