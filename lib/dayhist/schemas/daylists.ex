defmodule Dayhist.Daylists do
  alias Spotify.Playlist

  def list_daylists(params) do
    Flop.validate_and_run(Playlist, params, for: Playlist, repo: Dayhist.Repo)
  end

  def list_daylists(params, user_id) do
    list_daylists(params |> Map.put(:user_id, user_id))
  end
end
