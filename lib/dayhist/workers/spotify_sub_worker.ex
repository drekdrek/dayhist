defmodule Dayhist.Workers.SpotifyPlaylistWorker do
  @moduledoc false
  use Oban.Worker, queue: :spotify, max_attempts: 5
  alias Dayhist.{Repo, Schemas.SpotifyToken, Schemas.Daylist}

  @impl true
  def perform(%Oban.Job{args: %{"user_id" => user_id}}) do
    # Replace this with your function to get playlist information using Spotify API
    # get the most recent SpotifyToken
    spotify_token = Repo.one(SpotifyToken, order_by: [asc: :inserted_at])
    access_token = spotify_token.access_token

    daylist = get_playlists(user_id, access_token) |> get_daylist()

    # import daylist into the database
    Repo.insert(Daylist, %{
      user_id: user_id,
    })

  end

  defp get_playlists(user_id, access_token) do
    response = Req.get("")
  end

  defp get_daylist(playlists) do
  end
end
