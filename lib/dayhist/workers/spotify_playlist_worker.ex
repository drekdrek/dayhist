defmodule Dayhist.Workers.SpotifyPlaylistWorker do
  use Oban.Worker, queue: :spotify, max_attempts: 2
  alias Dayhist.Repo
  alias Dayhist.Schemas.{SpotifyToken, Daylist, Track}
  alias Phoenix.PubSub
  import Ecto.Query
  require Logger

  @daylist_id "37i9dQZF1EP6YuccBxUcC1"

  @impl Oban.Worker
  def perform(%Oban.Job{
        args: %{
          "user_id" => user_id,
          "client_id" => client_id,
          "client_secret" => client_secret
        }
      }) do
    Logger.info("getting spotify playlist for user #{user_id}")

    spotify_token =
      Repo.all(
        from st in SpotifyToken,
          where: st.spotify_id == ^user_id,
          order_by: [desc: st.expires_at],
          limit: 1
      )
      |> List.first()

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
        time_of_day = get_time_of_day(daylist["name"])

        if time_of_day != "" do
          query =
            from(d in Daylist,
              where:
                d.user_id == ^user_id and
                  d.spotify_playlist_name == ^daylist["name"] and
                  d.date == ^Date.utc_today(),
              select: count(d.uuid)
            )

          Repo.one(query)
          |> case do
            0 ->
              contents = daylist["tracks"]["items"] |> Enum.map(&Track.from_api_response/1)

              contents
              |> Enum.each(fn track_attrs ->
                # insert into the database, if it already exists, update it
                case Dayhist.Repo.get(Track, track_attrs.track_id) do
                  nil -> Track.changeset(%Track{}, track_attrs)
                  post -> Track.changeset(post, track_attrs)
                end
                |> IO.inspect(label: "before insert_or_update")
                |> Dayhist.Repo.insert_or_update()
              end)

              Repo.insert(%Daylist{
                user_id: user_id,
                spotify_playlist_id: daylist["external_urls"]["spotify"],
                date: Date.utc_today(),
                time_of_day: time_of_day,
                spotify_playlist_name: daylist["name"],
                spotify_playlist_image: daylist["images"] |> Enum.at(0) |> Map.get("url"),
                contents: contents |> Enum.map(fn track -> track.track_id end)
              })

              PubSub.broadcast(Dayhist.PubSub, "daylists:update", {:ok, user_id})

              PubSub.broadcast(Dayhist.PubSub, "stats:update", {
                :update,
                Dayhist.Schemas.Daylist.count(),
                Dayhist.Schemas.Track.count()
              })

              :ok

            _ ->
              :ok
          end
        else
          Logger.warning("Playlist name #{daylist["name"]} does not match the expected pattern.")
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

    delete_expired_tokens(user_id)
  end

  def delete_expired_tokens(user_id) do
    {_, to_delete} =
      Repo.all(
        from st in SpotifyToken,
          where: st.spotify_id == ^user_id and st.expires_at < ^DateTime.utc_now()
      )
      |> List.pop_at(0)

    Repo.delete_all(from st in SpotifyToken, where: st.id in ^Enum.map(to_delete, & &1.id))
  end

  defp strip_anchor_tags(html) do
    Regex.replace(~r/<\/?a[^>]*>/, html, "")
  end

  defp get_time_of_day(daylist_name) do
    # get the last two words of the daylist name
    words = String.split(daylist_name, " ")

    time_of_day =
      case Enum.reverse(words) do
        # thanks jeff for making me remember the word penultimate haha
        [last | [penultimate | _]] when penultimate in ["early", "late"] ->
          String.downcase("#{penultimate} #{last}")

        [last | _] ->
          String.downcase(last)

        _ ->
          ""
      end

    if time_of_day in [
         "early morning",
         "late night",
         "evening",
         "morning",
         "afternoon",
         "night"
       ] do
      time_of_day
    else
      ""
    end
  end
end
