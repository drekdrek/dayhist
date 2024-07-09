defmodule Dayhist.Repo.Migrations.AddUsersAndDaylists do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :serial, primary_key: true
      add :user_id, :string
      add :auto_fetch, :boolean, default: false
      add :name, :string
      add :spotify_id, :string
      add :spotify_access_token, :string
      add :spotify_refresh_token, :string
      add :spotify_expires_at, :utc_datetime
      timestamps()
    end

    # Add unique index to user_id
    create unique_index(:users, [:user_id])

    create table(:daylists, primary_key: false) do
      add :id, :serial, primary_key: true
      add :user_id, :string
      add :name, :string
      add :spotify_playlist_id, :string
      add :spotify_playlist_name, :string
      add :spotify_playlist_image, :string
      add :time_of_day, :string

      timestamps()
    end

    create index(:daylists, [:user_id])

    alter table(:daylists) do
      modify :user_id, references(:users, column: :user_id, type: :string, on_delete: :delete_all)
    end
  end
end
