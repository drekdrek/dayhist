defmodule Dayhist.Repo.Migrations.DeletePlaylistOnUserDeletion do
  use Ecto.Migration

  @schema_prefix "spotify"
  def change do
    alter table(:playlist, prefix: @schema_prefix) do
      modify :user_id,
             references(:user,
               prefix: "dayhist",
               column: :id,
               type: :string,
               on_delete: :delete_all
             )
    end
  end
end
