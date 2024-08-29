defmodule DayhistWeb.Components.Header do
  use DayhistWeb, :html

  def render(assigns) do
    ~H"""
    <header class="px-4 sm:px-6 lg:px-8 max-h-14 absolute w-full">
      <div class="flex items-center justify-between border-b dark:border-zinc-100 border-zinc-700  py-3 text-sm">
        <a href="/">
          <div class="inline-flex items-center gap-2 text-xl font-bold font-mono dark:text-white">
            <svg xmlns="http://www.w3.org/2000/svg" height="32" viewBox="0 0 448 512" class="dark:fill-white">
              <!--!Font Awesome Free 6.5.2 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license/free Copyright 2024 Fonticons, Inc.-->
              <path d="M128 0c17.7 0 32 14.3 32 32V64H288V32c0-17.7 14.3-32 32-32s32 14.3 32 32V64h48c26.5 0 48 21.5 48 48v48H0V112C0 85.5 21.5 64 48 64H96V32c0-17.7 14.3-32 32-32zM0 192H448V464c0 26.5-21.5 48-48 48H48c-26.5 0-48-21.5-48-48V192zm64 80v32c0 8.8 7.2 16 16 16h32c8.8 0 16-7.2 16-16V272c0-8.8-7.2-16-16-16H80c-8.8 0-16 7.2-16 16zm128 0v32c0 8.8 7.2 16 16 16h32c8.8 0 16-7.2 16-16V272c0-8.8-7.2-16-16-16H208c-8.8 0-16 7.2-16 16zm144-16c-8.8 0-16 7.2-16 16v32c0 8.8 7.2 16 16 16h32c8.8 0 16-7.2 16-16V272c0-8.8-7.2-16-16-16H336zM64 400v32c0 8.8 7.2 16 16 16h32c8.8 0 16-7.2 16-16V400c0-8.8-7.2-16-16-16H80c-8.8 0-16 7.2-16 16zm144-16c-8.8 0-16 7.2-16 16v32c0 8.8 7.2 16 16 16h32c8.8 0 16-7.2 16-16V400c0-8.8-7.2-16-16-16H208zm112 16v32c0 8.8 7.2 16 16 16h32c8.8 0 16-7.2 16-16V400c0-8.8-7.2-16-16-16H336c-8.8 0-16 7.2-16 16z" />
            </svg>
            <span class="font-mono">dayhi<span class="font-sans-serif">.</span>st</span>
          </div>
        </a>
        <div class="text-left text-zinc-700 dark:text-zinc-200 text-lg font-sans-serif">
          Total Daylists: <%= @playlist_count %> <span class="px-1">|</span> Total Songs: <%= @song_count %>
        </div>
        <div class="flex items-center gap-4 font-semibold leading-6 text-zinc-900">
          <div class="divide x divide-zinc-500">
            <div class="flex items-center dark:text-white">
              <%= if @user_info do %>
                <p class="gap-4">Logged in as:</p>
                <div class="pl-2 flex items-center gap-1">
                  <img src={@user_info.image} class="h-8 w-8 rounded-full " />
                  <p>
                    <%= @user_info.name %>
                  </p>
                </div>
                <.link
                  href={~p"/auth/logout?redirect_uri=" <> @__path__}
                  method="delete"
                  class="hover:text-zinc-400 dark:hover:text-zinc-500 pl-4"
                >
                  Logout
                </.link>
              <% else %>
                <.link
                  href={~p"/auth/spotify?redirect_uri=" <> @__path__}
                  method="get"
                  class="hover:text-zinc-400 dark:hover:text-zinc-500 pl-4"
                >
                  Login with Spotify
                </.link>
              <% end %>
            </div>
          </div>
          <DayhistWeb.Components.ToggleTheme.render />
        </div>
      </div>
    </header>
    """
  end
end
