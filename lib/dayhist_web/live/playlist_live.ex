defmodule DayhistWeb.PlaylistLive do
  require Logger
  use DayhistWeb, :live_view

  alias Spotify.{Playlist, Track}
  import Ecto.Query
  # alias Dayhist.SpotifyAPI.AccessToken

  @uuid_regex ~r/([\d\w]{8})([\d\w]{4})([\d\w]{4})([\d\w]{4})([\d\w]{12})/

  def mount(_params, session, socket) do
    socket =
      socket
      |> assign(
        playlist: nil,
        playlist_owner: nil,
        user_info: session["spotify_info"],
        created_playlist_id: nil
      )

    socket
    |> ok(layout: {DayhistWeb.Layouts, :playlist})
  end

  defp _maybe_get_spotify_playlist_url(user_id, _playlist) do
    # if the user is not logged in, return empty string,
    # if they do, query the SpotifyApi to see if they have a playlist matching with this playlist. if they do, return that url, otherwise return empty string
    if user_id do
      "example_url"
    else
      ""
    end
  end

  def handle_event("delete_playlist", _, socket) do
    sa = socket.assigns

    # double check that the user is the owner of the playlist
    if sa.user_info.nickname == sa.playlist.user_id do
      Spotify.PlaylistBehavior.delete_playlist(sa.playlist.uuid)
    end

    socket
    |> assign(:playlist, nil)
    |> redirect(to: ~p"/")
    |> noreply()
  end

  def handle_event("add_to_spotify", _, socket) do
    sa = socket.assigns

    playlist_id =
      Dayhist.SpotifyAPI.CreatePlaylist.create_playlist_and_populate(
        sa.user_info.nickname,
        {
          "#{sa.playlist_owner}'s #{sa.playlist.spotify_playlist_name}",
          "This daylist is from #{sa.playlist.date |> Date.to_string()}. created with https://dayhi.st",
          true
        },
        sa.playlist.contents
      )

    socket
    |> assign(:created_playlist_id, playlist_id)
    |> noreply()
  end

  def handle_params(%{"playlist" => playlist}, uri, socket) do
    %URI{
      path: path
    } = URI.parse(uri)

    socket =
      socket |> assign(__path__: path)

    playlist_uuid = uuid_to_dashed_uuid(playlist)

    playlist =
      try do
        from(d in Playlist, where: d.uuid == ^playlist_uuid) |> Dayhist.Repo.one()
      rescue
        _ ->
          nil
      end

    tracks =
      if playlist do
        from(t in Track, where: t.id in ^playlist.contents) |> Dayhist.Repo.all()
      else
        []
      end

    %{"display_name" => owner} =
      if playlist do
        Dayhist.SpotifyAPI.QueryUser.get_user(playlist.user_id)
      else
        %{"display_name" => "Unknown Username"}
      end

    socket
    |> assign(
      playlist: playlist,
      tracks: tracks,
      playlist_owner: owner,
      page_title:
        if playlist do
          playlist.name |> String.replace("daylist • ", "")
        else
          "Playlist not found"
        end
    )
    |> noreply()
  end

  defp uuid_to_dashed_uuid(playlist_uuid),
    do: playlist_uuid |> String.replace(@uuid_regex, "\\1-\\2-\\3-\\4-\\5")

  defp add_links(description) do
    regex = ~r|<a href="spotify:playlist:(?<id>[^"]+)">(?<name>[^<]+)</a>|

    # Replace all matches in the given html_string.
    Regex.replace(regex, description, fn _full_match, id, name ->
      "<a class= \"text-blue-500\" href=\"https://open.spotify.com/playlist/#{id}\">#{name}</a>"
    end)
  end
end
