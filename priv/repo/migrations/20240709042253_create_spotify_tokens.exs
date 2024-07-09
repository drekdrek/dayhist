defmodule Dayhist.Repo.Migrations.CreateSpotifyTokens do
  use Ecto.Migration

  def change do
    create table(:spotify_tokens) do
      add :access_token, :string, null: false
      add :expires_at, :utc_datetime, null: false

      timestamps()
    end
  end
end
