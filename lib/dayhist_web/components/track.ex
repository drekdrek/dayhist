defmodule DayhistWeb.Components.Track do
  use Phoenix.Component

  def render(assigns) do
    ~H"""
    <div class="hover:scale-[115%] transition ease-in-out duration-200">
      <.link href={"https://open.spotify.com/track/#{@track.id}"} class="text-blue-500 ">
        <div class="border border-gray-300 dark:border-zinc-700 p-2 rounded-lg flex flex-col transition ease-in-out duration-200 hover:bg-gray-200 dark:hover:bg-zinc-800 text-left font-sans-serif">
          <div class="flex items-start gap-2 items-center ">
            <img src={@track.image} class="h-16 w-16 rounded-lg transform" />
            <div>
              <p class="text-sm text-gray-700 dark:text-zinc-200">
                <%= @track.name %>
              </p>
              <p class="text-xs text-gray-500 dark:text-zinc-400">
                <%= @track.artists |> Enum.join(", ") %>
              </p>
            </div>
          </div>
        </div>
      </.link>
    </div>
    """
  end
end
