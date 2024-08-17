defmodule Dayhist.Spotify.Supervisor do
  use GenServer

  import Ecto.Query
  alias Dayhist.Repo
  alias Meta.User
  require Logger

  @hour_in_ms 60 * 60 * 1000

  def start_link(_) do
    Logger.info("start_link")
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    Logger.info("init")
    Process.send(self(), :run_workers, [])
    {:ok, []}
  end

  def handle_info(:run_workers, _) do
    Logger.info("handle_info(:run_workers, _)")
    users = fetch_users_from_db()
    run_workers(users)
    schedule_next_run()
    {:noreply, users}
  end

  def handle_info({:start_worker, user_id}, users) do
    Dayhist.Worker.start_link(user_id)
    {:noreply, users}
  end

  defp schedule_next_run do
    Process.send_after(self(), :run_workers, @hour_in_ms)
  end

  defguardp list_is_empty(list) when list == []

  defp run_workers(users) when list_is_empty(users) do
    Logger.info("No users to run workers for.")
    schedule_next_run()
  end

  defp run_workers(users) do
    user_count = length(users)
    interval = @hour_in_ms / user_count
    interval_string = :io_lib.format("~.1f", [interval]) |> List.to_string() |> String.trim()

    Logger.debug("Starting to run workers for #{user_count} users with an interval of #{interval_string} ms.")

    users
    |> Enum.with_index()
    |> Enum.each(fn {user, index} ->
      delay = round(index * interval)

      Process.send_after(self(), {:start_worker, user.id}, delay)
    end)

    Logger.debug("All workers have been scheduled.")
  end

  defp fetch_users_from_db do
    Repo.all(from u in User, where: u.auto_fetch == true, select: u)
  end
end
