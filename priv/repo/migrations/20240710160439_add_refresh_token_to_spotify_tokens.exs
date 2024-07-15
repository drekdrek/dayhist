defmodule Dayhist.Repo.Migrations.AddRefreshTokenToSpotifyTokens do
  use Ecto.Migration

  def change do
    alter table(:spotify_tokens) do
      add :refresh_token, :string
    end
  end
end
