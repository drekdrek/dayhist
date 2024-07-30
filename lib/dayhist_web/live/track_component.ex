defmodule DayhistWeb.TrackComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~H"""
    <div class="hover:scale-105 transition ease-in-out duration-200">
      <.link href={@track["track"]["external_urls"]["spotify"]} class="text-blue-500 ">
        <div class="border border-gray-300 dark:border-zinc-700 p-2 rounded-lg flex flex-col transition ease-in-out duration-200 hover:bg-gray-200 dark:hover:bg-zinc-800 text-left font-sans-serif">
          <div class="flex items-start gap-2 items-center ">
            <img
              src={@track["track"]["album"]["images"] |> Enum.at(0) |> Map.get("url")}
              class="h-16 w-16 rounded-lg transform"
            />
            <div>
              <p class="text-sm text-gray-700 dark:text-zinc-200">
                <%= @track["track"]["name"] %>
              </p>
              <p class="text-xs text-gray-500 dark:text-zinc-400">
                <%= Enum.map(@track["track"]["artists"], fn artist -> artist["name"] end)
                |> Enum.join(", ") %>
              </p>
            </div>
          </div>
        </div>
      </.link>
    </div>
    """
  end
end
