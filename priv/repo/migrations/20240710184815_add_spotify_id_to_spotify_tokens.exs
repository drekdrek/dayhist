defmodule Dayhist.Repo.Migrations.AddSpotifyIdToSpotifyTokens do
  use Ecto.Migration

  def change do
    alter table(:spotify_tokens) do
      add :spotify_id, :string
    end
  end
end
