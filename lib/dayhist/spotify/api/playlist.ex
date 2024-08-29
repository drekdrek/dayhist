defmodule Dayhist.SpotifyAPI.Playlist do
  alias Dayhist.SpotifyAPI.AccessToken
  require Logger

  def get(access_token, playlist_id) do
    case Req.get("https://api.spotify.com/v1/playlists/#{playlist_id}",
           headers: [{"Authorization", "Bearer #{access_token}"}]
         ) do
      {:ok, response} ->
        response.body

      {:error, reason} ->
        Logger.error("Failed to get playlist: #{reason}")
        nil
    end
  end

  defp create_playlist(access_token, user_id, {name, description, public?}) do
    json = %{
      "name" => name,
      "description" => description,
      "public" => public?
    }

    Req.post("https://api.spotify.com/v1/users/#{user_id}/playlists",
      headers: %{
        "Authorization" => "Bearer #{access_token}",
        "Content-Type" => "application/json"
      },
      json: json
    )
  end

  defp populate_playlist(access_token, playlist_id, contents) do
    json = %{
      "uris" =>
        Spotify.TrackBehavior.get_tracks(contents)
        |> Enum.map(fn track -> "spotify:track:#{track.id}" end)
    }

    Req.post("https://api.spotify.com/v1/playlists/#{playlist_id}/tracks",
      headers: %{
        "Authorization" => "Bearer #{access_token}",
        "Content-Type" => "application/json"
      },
      json: json
    )
  end

  def create(user_id, {name, description, public?}, contents \\ []) do
    access_token = AccessToken.get(user_id)

    {:ok, %Req.Response{status: 201, body: %{"id" => playlist_id}}} =
      create_playlist(access_token, user_id, {name, description, public?})

    unless contents == [] do
      populate_playlist(access_token, playlist_id, contents)
    end

    playlist_id
  end
end
