defmodule Spotify.Playlist do
  use Ecto.Schema
  import Ecto.Query
  import Ecto.Changeset

  @schema_prefix "spotify"

  @derive {
    Flop.Schema,
    filterable: [:time_of_day, :date], sortable: [:date]
  }

  @primary_key {:uuid, Ecto.UUID, autogenerate: true}
  schema "playlist" do
    field :user_id, :string
    field :playlist_id, :string
    field :name, :string
    field :image, :string
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
      :playlist_id,
      :name,
      :image,
      :date,
      :time_of_day,
      :contents,
      :description
    ])
    |> validate_required([
      :playlist_id,
      :user_id,
      :date
    ])
  end

  def count, do: from(d in Spotify.Playlist, select: count(d.uuid)) |> Dayhist.Repo.one()
end
