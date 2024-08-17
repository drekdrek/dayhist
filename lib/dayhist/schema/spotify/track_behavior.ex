defmodule Spotify.TrackBehavior do
  alias Dayhist.Repo
  alias Spotify.{Track, Playlist}
  import Ecto.Query

  def get_track(track_id) do
    from(t in Track, where: t.id == ^track_id) |> Repo.one()
  end

  def get_tracks(track_ids) when is_list(track_ids) do
    from(t in Track, where: t.id in ^track_ids) |> Repo.all()
  end

  def delete_if_orphan(track_id) do
    playlist = from(p in Playlist, where: ^track_id in p.contents) |> Repo.all()

    if playlist == [] do
      delete(track_id)
    end
  end

  defp delete(track_id), do: get_track(track_id) |> Repo.delete()

  def count, do: from(t in Track, select: count(t.id)) |> Repo.one()
end
