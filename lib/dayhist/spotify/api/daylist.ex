defmodule Dayhist.SpotifyAPI.QueryDaylist do
  @playlist_id "37i9dQZF1EP6YuccBxUcC1"

  alias Dayhist.SpotifyAPI.{AccessToken, Playlist}

  def get(user_id) do
    user_id
    |> AccessToken.get()
    |> Playlist.get(@playlist_id)
  end
end
