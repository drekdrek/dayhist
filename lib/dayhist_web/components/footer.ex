defmodule DayhistWeb.Compoents.Footer do
  use DayhistWeb, :html

  def render(assigns) do
    ~H"""
    <footer>
      <div class="flex flex-col items-center justify-center space-y-1 ">
        <%= if @user_info do %>
          <div>
            <.link href={~p"/delete-my-data"}>
              <span class="text-sm text-zinc-500 underline dark:text-zinc-200 font-sans-serif">
                Delete my data
              </span>
            </.link>
          </div>
        <% end %>
        <p class="text-center text-sm text-zinc-500 dark:text-zinc-200">
          <span class="font-mono">dayhi<span class="font-sans-serif">.</span>st</span> is not affiliated with Spotify.
        </p>

        <div class="text-sm text-zinc-500 dark:text-zinc-200 font-sans-serif">
          <span class="font-mono">dayhi<span class="font-sans-serif">.</span>st</span>
          you can report bugs and request features on our
          <.link
            href="https://github.com/drekdrek/dayhist"
            method="get"
            class="hover:text-zinc-500 text-blue-500 dark:hover:text-zinc-300 dark:text-blue-300"
          >
            GitHub
          </.link>
          page
        </div>
        <div
          class="inline-flex items-center gap-2 text-sm text-zinc-500 pb-2 dark:text-zinc-200 font-sans-serif"
          style="max-height: 24px;"
        >
          <p>
            if you like <span class="pl-0.5 font-mono">dayhi.st</span>, consider a small donation to help keep it running.
          </p>
          <a href="https://ko-fi.com/owenhalliday">
            <img src="/images/kofi.png" alt="Donate on Ko-fi" width="150" />
          </a>
        </div>
      </div>
    </footer>
    """
  end
end
