defmodule Dayhist.Schemas.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :user_id, :string
    field :auto_fetch, :boolean, default: false
    field :name, :string
    field :spotify_id, :string

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [
      :id,
      :user_id,
      :auto_fetch,
      :name,
      :spotify_i
    ])
    |> validate_required([:user_id, :name, :spotify_id])
  end
end
