defmodule Dayhist.Repo.Migrations.RemoveSpotifyIdFromUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove :spotify_id
    end
  end
end
