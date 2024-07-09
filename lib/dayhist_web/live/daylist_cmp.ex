defmodule DayhistWeb.DaylistCmp do
  use Phoenix.LiveComponent

  def mount(socket) do
    socket
    |> init()
    |> ok()
  end

  def init(socket) do
    socket
  end

  defp ok(socket) do
    {:ok, socket}
  end
end
