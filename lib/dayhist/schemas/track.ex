defmodule Dayhist.Schemas.Track do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  # basically store everything but the available_markets key

  # what we're gonna store:
  # track.id
  # track.uri
  # track.name
  # track.album.images[0].url
  # track.external_urls.spotify
  # track.artists[*].name
  @primary_key {:track_id, :string, []}
  schema "tracks" do
    # uri can be created by doing "spotify:track:#{track_id}"
    # field :uri, :string
    field :name, :string
    field :album_image_url, :string
    # spotify_url can be created by doing "https://open.spotify.com/track/#{track_id}"
    # field :spotify_url, :string
    field :artists, {:array, :string}
  end

  def changeset(track, attrs) do
    track
    |> cast(attrs, [:track_id, :name, :album_image_url, :artists])
    |> validate_required([:track_id, :name, :album_image_url, :artists])
  end

  def from_api_response(%{
        "track" => %{
          "id" => track_id,
          "name" => name,
          "album" => %{"images" => [%{"url" => album_image_url} | _]},
          "artists" => artists,
        }
      }) do
    artists_list = Enum.map(artists, & &1["name"])

    %{
      track_id: track_id,
      name: name,
      album_image_url: album_image_url,
      artists: artists_list,
    }
  end

  def count, do: from(t in Dayhist.Schemas.Track, select: count(t.track_id)) |> Dayhist.Repo.one()
end
