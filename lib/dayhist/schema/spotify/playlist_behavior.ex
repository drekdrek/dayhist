defmodule Spotify.PlaylistBehavior do
  alias Spotify.Playlist
  alias Dayhist.Repo
  import Ecto.Query

  def delete_playlist(uuid) do
    playlist = from(d in Playlist, where: d.uuid == ^uuid) |> Repo.one()

    playlist.contents
    |> Enum.each(&Spotify.TrackBehavior.delete_if_orphan/1)
  end

  def get_playlists(user_id) do
    from(d in Playlist, where: d.user_id == ^user_id)
    |> Repo.all()
  end

  def get_playlist(uuid) do
    from(d in Playlist, where: d.uuid == ^uuid)
    |> Repo.one()
  end

  def count, do: from(d in Playlist, select: count(d.uuid)) |> Repo.one()
end
