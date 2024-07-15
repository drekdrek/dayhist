defmodule Dayhist.Workers.SpotifyPlaylistWorker do
  @moduledoc false
  use Oban.Worker, queue: :spotify, max_attempts: 5
  alias Dayhist.{Repo, Schemas.SpotifyToken, Schemas.Daylist}

  import Ecto.Query
  require Logger

  @daylist_id "37i9dQZF1EP6YuccBxUcC1"
  @regex ~r/daylist • .* (evening|morning|afternoon|night)/

  @impl Oban.Worker
  def perform(%Oban.Job{
        args: %{"user_id" => user_id, "client_id" => client_id, "client_secret" => client_secret}
      }) do
    Logger.info("getting spotify playlist for user #{user_id}")

    # Replace this with your function to get playlist information using Spotify API
    # get the most recent SpotifyToken
    spotify_token =
      Repo.one(
        from st in SpotifyToken, where: st.spotify_id == ^user_id, order_by: [asc: st.inserted_at]
      )

    spotify_token =
      if DateTime.diff(spotify_token.expires_at, DateTime.utc_now()) < 0 do
        Logger.info("refreshing spotify token")
        refresh_token(spotify_token, client_id, client_secret)
      else
        spotify_token
      end

    Logger.info("get_playlists(user_id: #{user_id}, access_token: #{spotify_token.access_token})")

    case get_daylist(spotify_token.access_token) do
      {:ok, daylist} ->
        case Regex.run(@regex, daylist["name"]) do
          [_, captured_group] ->
            Logger.info("Captured group: #{captured_group}")

          Repo.insert(Daylist, %{
            user_id: user_id,
            spotify_playlist_id: daylist["external_urls"]["spotify"],
            date: Date.utc_today(),
            time_of_day: captured_group
          })

          :ok

          _ ->
            Logger.warning("Playlist name does not match the expected pattern.")
            {:error, :invalid_playlist_name}
        end

      {:error, reason} ->
        Logger.error("Failed to get daylist: #{reason}")
        {:error, reason}
    end
  end

  defp get_daylist(access_token) do
    response =
      Req.get!("https://api.spotify.com/v1/playlists/#{@daylist_id}",
        headers: [{"Authorization", "Bearer #{access_token}"}]
      )
      |> Logger.info(label: "response_daylist")

    if response.status_code == 200 do
      {:ok, Jason.decode!(response.body)}
    else
      {:error, response.status_code}
    end
  end

  defp refresh_token(spotify_token, client_id, client_secret) do
    auth = Base.encode64(client_id <> ":" <> client_secret)

    headers = %{
      "Authorization" => "Basic #{auth}",
      "Content-Type": "application/x-www-form-urlencoded"
    }

    form =
      %{
        "grant_type" => "refresh_token",
        "refresh_token" => spotify_token.refresh_token
      }
      |> URI.encode_query()

    response =
      Req.post("https://accounts.spotify.com/api/token", headers: headers, body: form)

    case response do
      {:ok, %Req.Response{status: status, body: body}} when status in 200..299 ->
        store_token(spotify_token.spotify_id, body)

        %{
          access_token: body["access_token"],
          refresh_token: body["refresh_token"]
        }

      {:ok, %Req.Response{status: status, body: _body}} when status == 429 ->
        Logger.warning("rate limited, retrying in 10 seconds")
        # retry(client_id, client_secret, 10)
        {:error, :rate_limited}

      _ ->
        Logger.error("something went wrong with the Spotify API")
        nil
    end
  end

  defp store_token(user_id, %{
         access_token: access_token,
         refresh_token: refresh_token,
         expires_at: expires_at
       }) do
    Logger.info("storing spotify token")

    # add the new token to the database

    %SpotifyToken{}
    |> SpotifyToken.changeset(%{
      user_id: user_id,
      access_token: access_token,
      refresh_token: refresh_token,
      expires_at: DateTime.add(DateTime.utc_now(), expires_at + 10, :second)
    })
    |> Repo.insert(
      on_conflict: {:replace_all, [:access_token, :refresh_token, :expires_at]},
      conflict_target: [:user_id]
    )

    #remove tokens that are expired
    # Repo.one(SpotifyToken, order_by: [asc: :inserted_at])
    # |> Repo.delete()
  end
end
