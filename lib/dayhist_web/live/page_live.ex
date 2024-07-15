defmodule DayhistWeb.PageLive do
  require Logger
  use DayhistWeb, :live_view

  import Ecto.Query

  def mount(_params, session, socket) do
    # query the database and get the user's auto_fetch setting

    db_user =
      if session["spotify_info"],
        do:
          Dayhist.Schemas.User |> Dayhist.Repo.get_by(user_id: session["spotify_info"].nickname),
        else: nil

    autofetch =
      if db_user do
        db_user
        |> Map.get(:auto_fetch, false)
      else
        false
      end

    socket =
      socket
      |> assign(:form, to_form(%{"auto_fetch" => autofetch}))
      |> assign(:user_info, session["spotify_info"])
      |> assign(:user_credentials, session["spotify_credentials"])

    {:ok, socket}
  end

  def handle_event("change", %{"auto_fetch" => auto_fetch}, socket) do
    autofetch = if auto_fetch == "true", do: true, else: false

    if autofetch do
      Logger.info("adding user " <> socket.assigns.user_info.nickname <> " to autofetch list")
    else
      Logger.info("removing user " <> socket.assigns.user_info.nickname <> " from autofetch list")
    end

    user =
      Dayhist.Repo.one(
        from u in Dayhist.Schemas.User, where: u.user_id == ^socket.assigns.user_info.nickname
      )

    if user do
      changeset =
        user
        |> Dayhist.Schemas.User.changeset(%{auto_fetch: autofetch})

      # Use the changeset to update the user
      case Dayhist.Repo.update(changeset) do
        {:ok, _updated_user} ->
          # Handle the success case
          # Possibly update the socket assigns or trigger other logic
          {:noreply, assign(socket, :auto_fetch, autofetch)}

        {:error, changeset} ->
          Logger.error(changeset)
          # Handle the error case
          {:noreply, socket}
      end
    else
      # Handle the case where the user is not found
      {:noreply, socket}
    end
  end
end
