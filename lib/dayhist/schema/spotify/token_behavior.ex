defmodule Spotify.TokenBehavior do
  alias Spotify.Token
  alias Dayhist.Repo
  import Ecto.Query

  def get_all_tokens(user_id) do
    from(t in Token, where: t.user_id == ^user_id)
    |> Repo.all()
  end

  def get_most_recent_token(user_id) do
    Repo.all(
      from t in Token,
        where: t.user_id == ^user_id,
        order_by: [desc: t.expires_at],
        limit: 1
    )
    |> List.first()
  end

  def get_expired_tokens(user_id) do
    from(
      t in Token,
      # and t.expires_at < ^DateTime.utc_now()
      where: t.user_id == ^user_id,
      order_by: [desc: t.expires_at]
    )
    |> Repo.all()
  end

  def delete_tokens(token_ids) when is_list(token_ids) do
    from(
      t in Token,
      where: t.id in ^token_ids
    )
    |> Repo.delete_all()
  end
end
