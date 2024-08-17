defmodule Meta.UserBehavior do
  alias Dayhist.Repo
  alias Meta.User
  import Ecto.Query

  def get_all_autofetch() do
    from(u in User, where: u.auto_fetch == true) |> Repo.all()
  end
end
