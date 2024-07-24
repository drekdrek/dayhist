defmodule Dayhist.Daylists do
  alias Dayhist.Schemas.Daylist

  def list_daylists(params, _user_id) do
    IO.inspect(params)
    Flop.validate_and_run(Daylist, params, for: Daylist, repo: Dayhist.Repo)
  end

  def get_daylists_by_user_id(user_id) do
    Flop.validate_and_run(Daylist, %{user_id: user_id}, for: Daylist, repo: Dayhist.Repo)
  end
end
