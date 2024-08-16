defmodule Dayhist.Repo.Migrations.DayhistInit do
  use Ecto.Migration

  @schema_prefix "dayhist"

  def change do
    create table(:user, prefix: @schema_prefix, primary_key: false) do
      add :id, :string, primary_key: true
      add :auto_fetch, :boolean, default: false

      timestamps()
    end

    create index(:user, [:id], prefix: @schema_prefix)
  end
end
