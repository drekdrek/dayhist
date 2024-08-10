defmodule Dayhist.Worker do
  require Logger
  alias Dayhist.SpotifyAPI.QueryDaylist
  alias Dayhist.Schemas.{Track, Daylist}
  alias Dayhist.Repo

  def start_link(user_id) do
    Task.start_link(fn -> task(user_id) end)
  end

  def task(user_id) do
    Logger.info("User #{user_id} is working.")

    daylist = QueryDaylist.get_daylist(user_id)

    if daylist do
      insert_daylist(user_id, daylist)
    else
      Logger.info("User #{user_id} got no daylist.")
    end

    # Add the actual task logic here
  end

  defp insert_daylist(user_id, daylist) do
    time_of_day = get_time_of_day(daylist["name"])

    contents = daylist["tracks"]["items"] |> Enum.map(&Track.from_api_response/1)

    insert_contents(contents)

    content_ids = contents |> Enum.map(fn track -> track.track_id end)

    changeset =
      Daylist.changeset(%Daylist{}, %{
        user_id: user_id,
        spotify_playlist_id: daylist["external_urls"]["spotify"],
        date: Date.utc_today(),
        time_of_day: time_of_day,
        spotify_playlist_name: daylist["name"],
        spotify_playlist_image: daylist["images"] |> Enum.at(0) |> Map.get("url"),
        contents: content_ids,
        description: daylist["description"]
      })

    Logger.warning("changeset: #{inspect(changeset)}")

    existing_daylist =
      Repo.get_by(Daylist,
        user_id: user_id,
        time_of_day: time_of_day,
        contents: content_ids,
        spotify_playlist_name: daylist["name"],
        description: daylist["description"]
      )

    Logger.warning("existing_daylist: #{inspect(existing_daylist)}")

    if existing_daylist do
      Daylist.changeset(existing_daylist, changeset.changes)
      |> Repo.update()
    else
      Repo.insert(changeset)
      |> IO.inspect(label: "inserted")

      Phoenix.PubSub.broadcast(Dayhist.PubSub, "daylists:update", {:ok, user_id})

      Phoenix.PubSub.broadcast(Dayhist.PubSub, "stats:update", {
        :update,
        Dayhist.Schemas.Daylist.count(),
        Dayhist.Schemas.Track.count()
      })
    end
  end

  defp insert_contents(contents) do
    contents
    |> Enum.each(fn track ->
      case Dayhist.Repo.get(Track, track.track_id) do
        nil -> Track.changeset(%Track{}, track)
        post -> Track.changeset(post, track)
      end
      |> Dayhist.Repo.insert_or_update()
    end)
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
