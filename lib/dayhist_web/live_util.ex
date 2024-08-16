defmodule DayhistWeb.LiveUtil do
  @moduledoc """
  This module contains utility functions that will be usable in any LiveView.
  """
  @compile {:inline, noreply: 1}
  def noreply(socket), do: {:noreply, socket}

  @compile {:inline, ok: 2}
  def ok(socket, opts \\ []), do: {:ok, socket, opts}
end
