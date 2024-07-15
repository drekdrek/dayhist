defmodule Dayhist.Workers.SpotifyWorkDistributor do
  use Oban.Worker, queue: :default, max_attempts: 1

  require Logger
  import Ecto.Query

  alias Dayhist.Schemas.User

  alias Dayhist.Workers.{SpotifyPlaylistWorker, SpotifyWorkDistributor}

  @hour_in_seconds 60 * 60

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"client_id" => nil, "client_secret" => nil}} = _job) do
    Logger.info("no spotify credentials provided, skipping SpotifyWorkDistributor job")
    {:error, "no spotify credentials provided"}
  end

  @impl Oban.Worker
  def perform(
        %Oban.Job{args: %{"client_id" => client_id, "client_secret" => client_secret}} = _job
      ) do
    Logger.info("starting SpotifyWorkDistributor job")

    # query the database for all users with auto_fetch set to true
    users = Dayhist.Repo.all(from u in User, where: u.auto_fetch == true)

    interval = @hour_in_seconds / length(users)

    Enum.with_index(users, fn user, index ->
      schedule_time = index * interval

      Logger.info(
        "scheduling SpotifyPlaylistWorker job for user #{user.user_id} in #{schedule_time} seconds"
      )

      {:ok, _job} =
        %{
          "user_id" => user.user_id,
          "client_id" => client_id,
          "client_secret" => client_secret
        }
        |> SpotifyPlaylistWorker.new(
          queue: :spotify,
          max_attempts: 1,
          schedule_in: schedule_time
        )
        |> Oban.insert()
    end)

    SpotifyWorkDistributor.new(%{}, schedule_in: @hour_in_seconds)
    |> Oban.insert()

    :ok
  end
end
