defmodule Spotify.Track do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  @schema_prefix "spotify"

  # basically store everything but the available_markets key

  # what we're gonna store:
  # track.id
  # track.uri
  # track.name
  # track.album.images[0].url
  # track.external_urls.spotify
  # track.artists[*].name
  @primary_key {:id, :string, []}
  schema "track" do
    # uri can be created by doing "spotify:track:#{track_id}"
    # field :uri, :string
    field :name, :string
    field :image, :string
    # spotify_url can be created by doing "https://open.spotify.com/track/#{track_id}"
    # field :spotify_url, :string
    field :artists, {:array, :string}
  end

  def changeset(track, attrs) do
    track
    |> cast(attrs, [:id, :name, :image, :artists])
    |> validate_required([:id, :name, :image, :artists])
  end

  def from_api_response(%{
        "track" => %{
          "id" => id,
          "name" => name,
          "album" => %{"images" => [%{"url" => image} | _]},
          "artists" => artists
        }
      }) do
    artists_list = Enum.map(artists, & &1["name"])

    %{
      id: id,
      name: name,
      image: image,
      artists: artists_list
    }
  end

  def count, do: from(t in Spotify.Track, select: count(t.id)) |> Dayhist.Repo.one()
end
