defmodule DayhistWeb.AuthController do
  use DayhistWeb, :controller

  alias Spotify.Token

  require Logger
  import Ecto.Query

  plug Ueberauth

  @spec callback(Plug.Conn.t(), any) :: Plug.Conn.t()
  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    redirect_uri = get_session(conn, :redirect_uri) || "/"
    user_id = auth.info.nickname

    user =
      Dayhist.Repo.one(from u in Token, where: u.user_id == ^auth.info.nickname)

    if !user do
      Logger.info("creating user #{auth.info.nickname}")

      Dayhist.Repo.insert(%Meta.User{
        id: user_id,
        auto_fetch: false
      })
    end

    # Store the SpotifyToken in the database

    Dayhist.Repo.insert(%Token{
      access_token: auth.credentials.token,
      refresh_token: auth.credentials.refresh_token,
      expires_at: DateTime.from_unix!(auth.credentials.expires_at),
      user_id: auth.info.nickname
    })

    conn
    |> put_session(:spotify_credentials, auth.credentials)
    |> put_session(:spotify_info, auth.info)
    |> configure_session(renew: true)
    |> redirect(to: redirect_uri)
  end

  def callback(%{assigns: %{ueberauth_failure: failure}} = conn, _params) do
    redirect_uri = get_session(conn, :redirect_uri) || "/"
    Logger.warning("failure: #{inspect(failure)}")

    conn
    |> put_flash(:error, gettext("Error authenticating via Spotify"))
    |> configure_session(drop: true)
    |> redirect(to: redirect_uri)
  end

  def delete(conn, params) do
    redirect_uri = params["redirect_uri"] || "/"

    conn
    |> configure_session(drop: true)
    |> put_flash(:info, "Logged out successfully.")
    |> redirect(to: redirect_uri)
  end
end
