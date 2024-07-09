defmodule Dayhist.Workers.SpotifyTokenRefresher do
  use Oban.Worker, queue: :default, max_attempts: 1

  alias Dayhist.{Repo, Schemas.User, Schemas.SpotifyToken}

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"client_id" => client_id, "client_secret" => client_secret}}) do
    get_token(client_id, client_secret)

    Repo.all(User)
    |> Enum.each(fn user ->
      {:ok, _job} =
        Oban.insert(%Oban.Job{
          worker: Dayhist.Workers.SpotifyPlaylistWorker,
          args: %{"user_id" => user.id}
        })
    end)
  end

  defp get_token(client_id, client_secret) do
    response =
      Req.post("https://accounts.spotify.com/api/token",
        headers: [
          Authorization: "Basic #{Base.encode64(client_id <> ":" <> client_secret)}",
          "Content-Type": "application/x-www-form-urlencoded"
        ],
        body: [grant_type: "client_credentials"]
      )

    case response do
      {:ok, %Req.Response{status: status, body: body}} when status in 200..299 ->
        # 10 seconds before expiration
        expires_in = body["expires_in"] - 10
        token = body["access_token"]

        expiration = DateTime.add(DateTime.utc_now(), expires_in + 10, :second)
        store_token(token, expiration)

        schedule_refresh(client_id, client_secret, expires_in)

        {:ok, token}

      _ ->
        {:error, "something went wrong with the Spotify API"}
    end
  end

  defp store_token(token, expiration) do
    %SpotifyToken{}
    |> SpotifyToken.changeset(%{access_token: token, expires_at: expiration})
    |> Repo.insert(on_conflict: {:replace_all, [:access_token, :expires_at]}, conflict_target: [])

    #if theres more than 5 tokens, delete the oldest one
    if Repo.aggregate(SpotifyToken, :count, :id) > 5 do
      Repo.one(SpotifyToken, order_by: [asc: :inserted_at])
      |> Repo.delete()
    end
  end

  defp schedule_refresh(client_id, client_secret, delay) do
    %{
      client_id: client_id,
      client_secret: client_secret
    }
    |> Dayhist.Workers.SpotifyTokenRefresher.new(schedule_in: delay)
    |> Oban.insert()
  end
end
