defmodule Dayhist.Schemas.SpotifyToken do
  use Ecto.Schema
  import Ecto.Changeset

  schema "spotify_tokens" do
    field :access_token, :string
    field :expires_at, :utc_datetime

    timestamps()
  end

  def changeset(token, attrs) do
    token
    |> cast(attrs, [:access_token, :expires_at])
    |> validate_required([:access_token, :expires_at])
  end
end
