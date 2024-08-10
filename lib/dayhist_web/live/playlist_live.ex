defmodule DayhistWeb.PlaylistLive do
  require Logger
  use DayhistWeb, :live_view

  alias Dayhist.Schemas.{Daylist, Track}
  import Ecto.Query

  @uuid_regex ~r/([\d\w]{8})([\d\w]{4})([\d\w]{4})([\d\w]{4})([\d\w]{12})/

  def mount(_params, session, socket) do
    socket =
      socket
      |> assign(:playlist, nil)
      |> assign(:playlist_owner, nil)
      |> assign(:user_info, session["spotify_info"])

    {:ok, socket, layout: {DayhistWeb.Layouts, :playlist}}
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
        from(d in Daylist, where: d.uuid == ^playlist_uuid) |> Dayhist.Repo.one()
      rescue
        _ ->
          nil
      end

    tracks =
      if playlist do
        from(t in Track, where: t.track_id in ^playlist.contents) |> Dayhist.Repo.all()
      else
        []
      end

    %{"display_name" => owner} =
      if playlist do
        Dayhist.SpotifyAPI.QueryUser.get_user(playlist.user_id)
      else
        %{"display_name" => "Unknown Username"}
      end

    socket =
      socket
      |> assign(:playlist, playlist)
      |> assign(:tracks, tracks)
      |> assign(:playlist_owner, owner)
      |> assign(
        :page_title,
        if playlist do
          playlist.spotify_playlist_name |> String.replace("daylist • ", "")
        else
          "Playlist not found"
        end
      )

    {:noreply, socket}
  end

  defp uuid_to_dashed_uuid(playlist_uuid),
    do: playlist_uuid |> String.replace(@uuid_regex, "\\1-\\2-\\3-\\4-\\5")
end
