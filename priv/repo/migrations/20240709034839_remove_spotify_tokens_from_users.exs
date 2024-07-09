defmodule Dayhist.Repo.Migrations.RemoveSpotifyTokensFromUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove :spotify_access_token, :string
      remove :spotify_refresh_token, :string
      remove :spotify_expires_at, :utc_datetime
    end
  end
end
