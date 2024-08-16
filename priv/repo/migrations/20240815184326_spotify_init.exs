defmodule Dayhist.Repo.Migrations.SpotifyInit do
  use Ecto.Migration

  @schema_prefix "spotify"

  def change do
    create table(:token, prefix: @schema_prefix) do
      add :user_id, :string, null: false
      add :access_token, :text, null: false
      add :refresh_token, :text, null: false

      add :expires_at, :utc_datetime, null: false

      timestamps()
    end

    create table(:playlist, prefix: @schema_prefix, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :user_id, :string, null: false
      add :playlist_id, :string, null: false
      add :name, :string, null: false
      add :image, :string, null: false

      add :date, :date, null: false

      add :time_of_day, :string
      add :description, :text

      add :contents, {:array, :string}

      timestamps()
    end

    create table(:track, prefix: @schema_prefix, primary_key: false) do
      add :id, :string, null: false, primary_key: true
      add :name, :string, null: false
      add :image, :string, null: false
      add :artists, {:array, :string}
    end
  end
end
