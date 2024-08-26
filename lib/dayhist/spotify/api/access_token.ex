defmodule Dayhist.SpotifyAPI.AccessToken do
  alias Spotify.Token
  alias Spotify.TokenBehavior
  alias Dayhist.Repo
  require Logger
  @client_id Application.compile_env(:dayhist, :client_id, "")
  @client_secret Application.compile_env(:dayhist, :client_secret, "")

  @basic_auth "Basic " <> Base.encode64("#{@client_id}:#{@client_secret}")

  def get_access_token(user_id) do
    spotify_token = TokenBehavior.get_most_recent_token(user_id)

    spotify_token =
      if spotify_token.expires_at < DateTime.utc_now() do
        refresh_access_token(spotify_token.refresh_token)
        |> store_token(user_id)
      else
        %{
          "access_token" => spotify_token.access_token,
          "refresh_token" => spotify_token.refresh_token,
          "expires_at" => spotify_token.expires_at
        }
      end

    maybe_clean_up_expired_tokens(user_id)
    spotify_token["access_token"]
  end

  defp store_token(
         spotify_token,
         user_id
       ) do
    %Token{}
    |> Token.changeset(%{
      user_id: user_id,
      access_token: spotify_token["access_token"],
      refresh_token: spotify_token["refresh_token"],
      expires_at: DateTime.add(DateTime.utc_now(), spotify_token["expires_in"], :second)
    })
    |> Repo.insert()

    spotify_token
  end

  defp refresh_access_token(refresh_token) do
    # make a post request to the spotify api to refresh the access token
    headers = [
      {"Authorization", @basic_auth},
      {"Content-Type", "application/x-www-form-urlencoded"}
    ]

    form =
      %{
        "grant_type" => "refresh_token",
        "refresh_token" => refresh_token
      }
      |> URI.encode_query()

    response =
      Req.post("https://accounts.spotify.com/api/token", headers: headers, body: form)

    case response do
      {:ok, %Req.Response{status: status, body: body}} when status in 200..299 ->
        body |> Map.put("refresh_token", refresh_token)

      {:ok, %Req.Response{status: status, body: _body}} when status == 429 ->
        Logger.warning("rate limited")
        {:error, :rate_limited}

      _ ->
        Logger.error("something went wrong with the Spotify API, #{inspect(response)}")
        nil
    end
  end

  defp maybe_clean_up_expired_tokens(user_id) do
    {_, to_delete} =
      TokenBehavior.get_expired_tokens(user_id)
      |> Enum.reverse()
      |> List.pop_at(0)

    to_delete =
      Enum.map(to_delete, fn token -> token.id end)

    if length(to_delete) > 0 do
      TokenBehavior.delete_tokens(to_delete)
    end
  end
end
