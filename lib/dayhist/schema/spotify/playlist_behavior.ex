defmodule Spotify.PlaylistBehavior do
  alias Spotify.Playlist
  alias Dayhist.Repo
  import Ecto.Query

  defp broadcast_stats() do
    Phoenix.PubSub.broadcast(Dayhist.PubSub, "stats:update", {:update, Spotify.Playlist.count(), Spotify.Track.count()})
  end

  def delete_playlist(uuid) do
    playlist = from(d in Playlist, where: d.uuid == ^uuid) |> Repo.one()
    playlist |> Repo.delete()

    playlist.contents
    |> Enum.each(&Spotify.TrackBehavior.delete_if_orphan/1)

    broadcast_stats()

    :ok
  end

  def get_playlist_by_short_uuid(uuid) do
    uuid = uuid |> String.replace(~r/([\d\w]{8})([\d\w]{4})([\d\w]{4})([\d\w]{4})([\d\w]{12})/, "\\1-\\2-\\3-\\4-\\5")
    get_playlist(uuid)
  end

  def get_playlists(user_id) do
    from(d in Playlist, where: d.user_id == ^user_id)
    |> Repo.all()
  end

  def get_playlist(uuid) do
    from(d in Playlist, where: d.uuid == ^uuid)
    |> Repo.one()
  end

  def get_playlists_with_contents(track_id) do
    from(p in Playlist, where: ^track_id in p.contents) |> Repo.all()
  end

  def count, do: from(d in Playlist, select: count(d.uuid)) |> Repo.one()
end
