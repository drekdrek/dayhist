defmodule DayhistWeb.PageController do
  use DayhistWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def autofetch(conn, _params) do
    faq = [
      #   %{
      #     q: "What is dayhi.st Auto-fetch?",
      #     a:
      #       "Auto-fetch will automatically, every hour, attempt to fetch your Spotify Daylist and store it in dayhi.st's database."
      #   },
      #   %{
      #     q: "Why should i use dayhi.st?",
      #     a:
      #       "dayhi.st keeps track your daylists and allows you to easily access, save, and share them. "
      #   }
    ]

    conn =
      conn
      |> assign(:page_title, "dayhi.st FAQ")
      |> assign(:user_info, nil)
      |> assign(:faq, faq)

    render(conn, :autofetch, layout: false)
  end
end
