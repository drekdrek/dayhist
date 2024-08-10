defmodule Dayhist.Schemas.Daylist do
  use Ecto.Schema
  import Ecto.Query
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
    field :contents, {:array, :string}
    field :description, :string

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
      :contents,
      :description
    ])
    |> validate_required([
      :spotify_playlist_id,
      :user_id,
      :date
    ])
  end

  def count, do: from(d in Dayhist.Schemas.Daylist, select: count(d.uuid)) |> Dayhist.Repo.one()
end
