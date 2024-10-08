defmodule DayhistWeb.Plugs.SetCounts do
  import Plug.Conn
  alias Spotify.{Playlist, Track}
  def init(default), do: default

  def call(conn, _default) do
    playlist_count = Playlist.count()
    song_count = Track.count()

    conn
    |> assign(:playlist_count, playlist_count)
    |> assign(:song_count, song_count)
  end
end
