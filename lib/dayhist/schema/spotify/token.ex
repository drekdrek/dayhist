defmodule Spotify.Token do
  use Ecto.Schema
  import Ecto.Changeset

  @schema_prefix "spotify"

  schema "token" do
    field :user_id, :string
    field :access_token, :string
    field :refresh_token, :string
    field :expires_at, :utc_datetime

    timestamps()
  end

  def changeset(spotify_token, attrs) do
    spotify_token
    |> cast(attrs, [:access_token, :refresh_token, :expires_at, :user_id])
    |> validate_required([:access_token, :refresh_token, :expires_at, :user_id])
    # Add unique constraint here
    |> unique_constraint(:user_id, name: :spotify_tokens_pkey)
  end
end
