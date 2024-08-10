defmodule Dayhist.SpotifyAPI.QueryDaylist do
  @playlist_id "37i9dQZF1EP6YuccBxUcC1"

  alias Dayhist.SpotifyAPI.{AccessToken, QueryPlaylist}

  def get_daylist(user_id) do
    user_id
    |> AccessToken.get_access_token()
    |> QueryPlaylist.get_playlist(@playlist_id)
  end
end
