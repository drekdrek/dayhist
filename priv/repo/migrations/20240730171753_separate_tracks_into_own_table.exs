defmodule Dayhist.Repo.Migrations.SeparateTracksIntoOwnTable do
  use Ecto.Migration

  def change do
    alter table(:daylists) do
      remove :contents
      add :contents, {:array, :string}
    end
  end

  def up do
    create table(:tracks, primary_key: false) do
      add :track_id, :string, primary_key: true
      # uri can be created by doing "spotify:track:#{track_id}"
      # add :uri, :string
      add :name, :string
      add :album_image_url, :string
      # spotify_url can be created by doing "https://open.spotify.com/track/#{track_id}"
      # add :spotify_url, :string
      add :artists, {:array, :string}
    end
  end
end
