defmodule DayhistWeb.AuthController do
  @moduledoc """
  Controls authentication via the Spotify API.
  """
  use DayhistWeb, :controller

  require Logger

  plug Ueberauth

  @spec callback(Plug.Conn.t(), any) :: Plug.Conn.t()
  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
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
