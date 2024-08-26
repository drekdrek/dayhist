defmodule Meta.UserBehavior do
  alias Dayhist.Repo
  alias Meta.User
  import Ecto.Query

  def get_all_autofetch() do
    from(u in User, where: u.auto_fetch == true) |> Repo.all()
  end

  def delete_user(user_id) do
    # delete all the playlists that belong to this user
    Spotify.PlaylistBehavior.get_playlists(user_id)
    |> Enum.map(& &1.uuid)
    |> Enum.each(&Spotify.PlaylistBehavior.delete_playlist/1)

    # delete all the tokens that belong to this user
    Spotify.TokenBehavior.get_all_tokens(user_id)
    |> Enum.map(& &1.id)
    |> Spotify.TokenBehavior.delete_tokens()

    # delete the user
    from(u in User, where: u.id == ^user_id)
    |> Repo.delete()
  end
end
