defmodule DayhistWeb.PageController do
  use DayhistWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def autofetch(conn, _params) do
    conn = conn |> assign(:page_title, "Autofetch FAQ") |> assign(:user_info, nil)

    render(conn, :autofetch, layout: false)
  end
end
