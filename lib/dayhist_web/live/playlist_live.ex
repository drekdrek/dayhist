defmodule DayhistWeb.PlaylistLive do
  require Logger
  use DayhistWeb, :live_view

  alias Dayhist.Schemas.Daylist
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

  def handle_params(%{"playlist" => playlist}, _url, socket) do
    playlist_uuid = uuid_to_dashed_uuid(playlist)

    p =
      try do
        from(d in Daylist, where: d.uuid == ^playlist_uuid) |> Dayhist.Repo.one()
      rescue
        _ ->
          nil
      end

    socket =
      socket
      |> assign(:playlist, p)
      |> assign(
        :page_title,
        if p do
          p.spotify_playlist_name |> String.replace("daylist • ", "")
        else
          "Playlist not found"
        end
      )

    {:noreply, socket}
  end

  defp uuid_to_dashed_uuid(playlist_uuid),
    do: playlist_uuid |> String.replace(@uuid_regex, "\\1-\\2-\\3-\\4-\\5")

end
