defmodule Dayhist.SpotifyAPI.QueryPlaylist do
  require Logger

  def get_playlist(access_token, playlist_id) do
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
end
