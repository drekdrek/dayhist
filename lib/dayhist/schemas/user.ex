defmodule Dayhist.Schemas.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :user_id, :string
    field :auto_fetch, :boolean, default: false

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [
      :user_id,
      :auto_fetch
    ])
    |> cast(attrs, [:user_id, :auto_fetch])
    |> validate_required([:user_id])
  end
end
