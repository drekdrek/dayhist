defmodule Dayhist.Schemas.Daylist do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {
    Flop.Schema,
    filterable: [:time_of_day, :date], sortable: [:date]
  }

  @primary_key {:uuid, Ecto.UUID, autogenerate: true}
  schema "daylists" do
    field :user_id, :string
    field :spotify_playlist_id, :string
    field :spotify_playlist_name, :string
    field :spotify_playlist_image, :string
    field :date, :date
    field :time_of_day, :string
    field :contents, {:array, :map}

    timestamps()
  end

  def changeset(daylist, attrs) do
    daylist
    |> cast(attrs, [
      :user_id,
      :spotify_playlist_id,
      :spotify_playlist_name,
      :spotify_playlist_image,
      :date,
      :time_of_day,
      :contents
    ])
    |> validate_required([
      :spotify_playlist_id,
      :user_id,
      :date,
      :time_of_day
    ])
  end
end
