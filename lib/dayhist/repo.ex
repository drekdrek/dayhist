defmodule Dayhist.Repo do
  use Ecto.Repo,
    otp_app: :dayhist,
    adapter: Ecto.Adapters.Postgres
end
