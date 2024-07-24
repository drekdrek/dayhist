defmodule Dayhist.Repo.Migrations.AddDateToDaylist do
  use Ecto.Migration

  def change do
    alter table(:daylists) do
      add :date, :date
    end
  end
end
