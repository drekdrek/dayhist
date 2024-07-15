defmodule Dayhist.Schemas.Daylist do
  use Ecto.Schema
  import Ecto.Changeset

  schema "daylists" do
    field :user_id, :string
    field :spotify_playlist_id, :string
    field :spotify_playlist_name, :string
    field :spotify_playlist_image, :string
    field :date, :date
    field :time_of_day, Dayhist.TimeOfDay
    field :contents, :map

    timestamps()
  end

  def changeset(daylist, attrs) do
    daylist
    |> cast(attrs, [
      :id,
      :user_id,
      :spotify_playlist_id,
      :date,
      :time_of_day
    ])
    |> validate_required([
      :id,
      :spotify_playlist_id,
      :user_id,
      :date,
      :time_of_day
    ])
  end
end
