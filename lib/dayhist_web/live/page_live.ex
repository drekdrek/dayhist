defmodule DayhistWeb.PageLive do
  require Logger
  use DayhistWeb, :live_view

  alias Dayhist.Daylists

  import Flop.Phoenix

  import Ecto.Query

  def handle_params(params, uri, socket) do
    %URI{
      path: path
    } = URI.parse(uri)

    socket =
      socket |> assign(__path__: path)

    if socket.assigns.user_info do
      update_daylists(params, socket)
    else
      {:noreply, socket}
    end
  end

  def mount(_params, session, socket) do
    # query the database and get the user's auto_fetch setting

    Phoenix.PubSub.subscribe(Dayhist.PubSub, "daylists:update")
    Phoenix.PubSub.subscribe(Dayhist.PubSub, "stats:update")

    db_user =
      if session["spotify_info"],
        do: Dayhist.Schemas.User |> Dayhist.Repo.get_by(user_id: session["spotify_info"].nickname),
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
      |> assign(:daylists, nil)
      |> assign(:meta, nil)
      |> assign(:user_credentials, session["spotify_credentials"])

    {:ok, socket}
  end

  def handle_info({:ok, user_id}, socket) do
    # Ignore the message if the user_id doesn't match
    if user_id == socket.assigns.user_info.nickname do
      update_daylists(%{}, socket)
    else
      {:noreply, socket}
    end
  end

  def handle_info({:update, playlist_count, song_count}, socket) do
    socket =
      socket
      |> assign(:playlist_count, playlist_count)
      |> assign(:song_count, song_count)

    {:noreply, socket}
  end

  def handle_event("fetch-daylist", %{"id" => id}, socket) do
    # create a new worker to fetch the daylist
    user_id = socket.assigns.user_info.nickname

    Dayhist.Worker.start_link(user_id)

    socket =
      socket
      |> push_event("disable-button", %{id: id, timeout: 5000, text: "fetching daylist..."})

    {:noreply, socket}
  end

  def handle_event("change", %{"auto_fetch" => auto_fetch}, socket) do
    autofetch = if auto_fetch == "true", do: true, else: false

    if autofetch do
      Logger.info("adding user " <> socket.assigns.user_info.nickname <> " to autofetch list")
    else
      Logger.info("removing user " <> socket.assigns.user_info.nickname <> " from autofetch list")
    end

    user =
      Dayhist.Repo.one(from u in Dayhist.Schemas.User, where: u.user_id == ^socket.assigns.user_info.nickname)

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

  def handle_event("update-filter", params, socket) do
    params = Map.delete(params, "_target")
    {:noreply, push_patch(socket, to: ~p"/?#{params}")}
  end

  defp update_daylists(params, socket) do
    case Daylists.list_daylists(params, socket.assigns.user_info.nickname) do
      {:ok, {daylists, meta}} ->
        {:noreply, assign(socket, :daylists, daylists) |> assign(:meta, meta)}

      {:error, _meta} ->
        {:noreply, socket |> push_navigate(to: ~p"/")}
    end
  end

  def filter_form(%{meta: meta} = assigns) do
    assigns = assign(assigns, form: Phoenix.Component.to_form(meta), meta: nil)

    ~H"""
    <.form for={@form} id="daylist-form" phx-change="update-filter" phx-submit="update-filter" class="dark:text-white">
      <.filter_fields :let={i} form={@form} fields={[:name]}>
        <.input field={i.field} label={i.label} type={i.type} phx-debounce={120} {i.rest} />
      </.filter_fields>

      <button class="button" name="reset">reset</button>
    </.form>
    """
  end
end
