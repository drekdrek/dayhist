defmodule DayhistWeb.Plugs.RedirectPlug do
  import Plug.Conn

  def init(opts), do: opts

  @spec call(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def call(conn, _opts) do
    redirect_uri = conn.query_params["redirect_uri"]

    conn
    |> put_session(:redirect_uri, redirect_uri)
  end
end

