defmodule Dayhist.User do
  use Ecto.Schema
  import Ecto.Changeset

  @schema_prefix "dayhist"

  @primary_key {:id, :string, []}
  schema "user" do
    field :auto_fetch, :boolean, default: false

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [
      :id,
      :auto_fetch
    ])
    |> cast(attrs, [:id, :auto_fetch])
    |> unique_constraint(:id, name: :user_pkey)
    |> validate_required([:id])
  end
end
