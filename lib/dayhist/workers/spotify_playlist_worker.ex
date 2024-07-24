defmodule Dayhist.Workers.SpotifyPlaylistWorker do
  @moduledoc false
  use Oban.Worker, queue: :spotify, max_attempts: 2
  alias Dayhist.{Repo, Schemas.SpotifyToken, Schemas.Daylist}

  alias Phoenix.PubSub

  import Ecto.Query
  require Logger

  @daylist_id "37i9dQZF1EP6YuccBxUcC1"
  @regex ~r/daylist • .* (evening|morning|afternoon|night|early morning|late night)/

  @impl Oban.Worker
  def perform(%Oban.Job{
        args: %{
          "user_id" => user_id,
          "client_id" => client_id,
          "client_secret" => client_secret
        }
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

    get_and_store_daylist(user_id, spotify_token.access_token)
  end

  defp get_and_store_daylist(user_id, access_token) do
    case get_daylist(access_token) do
      {:ok, daylist} ->
        case Regex.run(@regex, daylist["name"]) do
          [_, captured_group] ->
            # Define the query to count records with specified filters
            query =
              from(d in Daylist,
                where:
                  d.user_id == ^user_id and
                    d.spotify_playlist_name == ^daylist["name"] and
                    d.date == ^Date.utc_today(),
                select: count(d.uuid)
              )

            # Run the query and handle the result
            Repo.one(query)
            |> case do
              0 ->
                # If no matching records are found, insert a new record
                Repo.insert(%Daylist{
                  user_id: user_id,
                  spotify_playlist_id: daylist["external_urls"]["spotify"],
                  date: Date.utc_today(),
                  time_of_day: captured_group,
                  spotify_playlist_name: daylist["name"],
                  spotify_playlist_image: daylist["images"] |> Enum.at(0) |> Map.get("url"),
                  contents: daylist["tracks"]["items"]
                })

                # send an message to the user, if they are online to update the page liveview
                PubSub.broadcast(Dayhist.PubSub, "daylists:update", {:ok, user_id})

                :ok

              _ ->
                :ok
            end

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
    {:ok, response} =
      Req.get("https://api.spotify.com/v1/playlists/#{@daylist_id}",
        headers: [{"Authorization", "Bearer #{access_token}"}]
      )

    if response.status == 200 do
      {:ok, response.body}
    else
      {:error, response.status}
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
        store_token(spotify_token.spotify_id, body, spotify_token.refresh_token)

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

  defp store_token(
         user_id,
         %{
           "access_token" => access_token,
           "expires_in" => expires_in,
           "token_type" => _token_type,
           "scope" => _scope
         },
         refresh_token
       ) do
    Logger.info("storing spotify token")

    # add the new token to the database

    %SpotifyToken{}
    |> SpotifyToken.changeset(%{
      user_id: user_id,
      access_token: access_token,
      refresh_token: refresh_token,
      expires_at: DateTime.add(DateTime.utc_now(), expires_in, :second)
    })
    |> Repo.insert(
      on_conflict: {:replace_all, [:access_token, :refresh_token, :expires_at]},
      conflict_target: [:user_id]
    )

    # remove tokens that are expired
    # Repo.one(SpotifyToken, order_by: [asc: :inserted_at])
    # |> Repo.delete()
  end
end
