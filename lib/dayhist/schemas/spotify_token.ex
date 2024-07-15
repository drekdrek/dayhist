defmodule Dayhist.Schemas.SpotifyToken do
  use Ecto.Schema
  import Ecto.Changeset

  schema "spotify_tokens" do
    field :access_token, :string
    field :refresh_token, :string
    field :expires_at, :utc_datetime
    field :spotify_id, :string

    timestamps()
  end

  def changeset(spotify_token, attrs) do
    spotify_token
    |> cast(attrs, [:access_token, :refresh_token, :expires_at, :spotify_id])
    |> validate_required([:access_token, :refresh_token, :expires_at, :spotify_id])
    # Add unique constraint here
    |> unique_constraint(:spotify_id, name: :spotify_tokens_pkey)
  end
end
