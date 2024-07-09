defmodule DayhistWeb.PageLive do
  use DayhistWeb, :live_view

  def mount(_params, session, socket) do
    socket =
      socket
      |> assign(:form, to_form(%{}))
      |> assign(:user_info, session["spotify_info"])
      |> assign(:user_credentials, session["spotify_credentials"])

    {:ok, socket}
  end

  def handle_event("change", %{"auto_fetch" => auto_fetch}, socket) do
    IO.inspect(auto_fetch, label: "auto_fetch")

    if auto_fetch == "true" do
      IO.inspect("adding user " <> socket.assigns.user_info.nickname <> " to autofetch list")
    else
      IO.inspect("removing user " <> socket.assigns.user_info.nickname <> " from autofetch list")
    end

    {:noreply, socket}
  end
end
