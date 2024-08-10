defmodule Dayhist.Daylists do
  alias Dayhist.Schemas.Daylist

  def list_daylists(params) do
    Flop.validate_and_run(Daylist, params, for: Daylist, repo: Dayhist.Repo)
  end

  def list_daylists(params, user_id) do
    list_daylists(params |> Map.put(:user_id, user_id))
  end
end
