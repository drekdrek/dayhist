defmodule Dayhist.Repo.Migrations.ReplaceIdWithUuidOnDaylist do
  use Ecto.Migration

  def change do
    alter table(:daylists) do
      remove :id
      add :uuid, :uuid, primary_key: true
    end
  end
end
