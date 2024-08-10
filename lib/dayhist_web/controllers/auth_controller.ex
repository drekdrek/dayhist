defmodule DayhistWeb.AuthController do
  @moduledoc """
  Controls authentication via the Spotify API.
  """
  use DayhistWeb, :controller

  require Logger
  import Ecto.Query

  plug Ueberauth

  @spec callback(Plug.Conn.t(), any) :: Plug.Conn.t()
  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    user_id = auth.info.nickname
    IO.inspect(auth)

    user =
      Dayhist.Repo.one(from u in Dayhist.Schemas.User, where: u.user_id == ^auth.info.nickname)

    if !user do
      Logger.info("creating user #{auth.info.nickname}")

      Dayhist.Repo.insert(%Dayhist.Schemas.User{
        user_id: user_id,
        auto_fetch: false
      })
    end

    # no matter what, store the SpotifyToken in the database

    Dayhist.Repo.insert(%Dayhist.Schemas.SpotifyToken{
      access_token: auth.credentials.token,
      refresh_token: auth.credentials.refresh_token,
      expires_at: DateTime.from_unix!(auth.credentials.expires_at),
      spotify_id: auth.info.nickname
    })

    conn
    |> put_session(:spotify_credentials, auth.credentials)
    |> put_session(:spotify_info, auth.info)
    |> configure_session(renew: true)
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_failure: failure}} = conn, _params) do
    Logger.warning("failure: #{inspect(failure)}")

    conn
    |> put_flash(:error, gettext("Error authenticating via Spotify"))
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end

  def delete(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> put_flash(:info, "Logged out successfully.")
    |> redirect(to: "/")
  end
end
