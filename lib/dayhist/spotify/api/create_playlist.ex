defmodule Dayhist.SpotifyAPI.CreatePlaylist do
  alias Dayhist.Schemas.Track
  alias Dayhist.Repo
  import Ecto.Query
  alias Dayhist.SpotifyAPI.AccessToken

  def headers(access_token) do
    %{
      "Authorization" => "Bearer #{access_token}",
      "Content-Type" => "application/json"
    }
  end

  defp create_playlist(access_token, user_id, {name, description, public?}) do
    json = %{
      "name" => name,
      "description" => description,
      "public" => public?
    }

    Req.post("https://api.spotify.com/v1/users/#{user_id}/playlists",
      headers: headers(access_token),
      json: json
    )
  end

  defp populate_playlist(access_token, playlist_id, contents) do
    json = %{
      "uris" =>
        from(t in Track,
          where: t.track_id in ^contents
        )
        |> Repo.all()
        |> Enum.map(fn track -> "spotify:track:#{track.track_id}" end)
    }

    Req.post("https://api.spotify.com/v1/playlists/#{playlist_id}/tracks",
      headers: headers(access_token),
      json: json
    )
  end

  def create_playlist_and_populate(user_id, {name, description, public?}, contents) do
    access_token = AccessToken.get_access_token(user_id)

    {:ok, %Req.Response{status: 201, body: %{"id" => playlist_id}}} =
      create_playlist(access_token, user_id, {name, description, public?})

    populate_playlist(access_token, playlist_id, contents)

    playlist_id
  end
end
