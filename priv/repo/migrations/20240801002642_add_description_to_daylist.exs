defmodule Dayhist.Repo.Migrations.AddDescriptionToDaylist do
  use Ecto.Migration

  def change do
    alter table(:daylists) do
      add :description, :text
    end
  end
end
