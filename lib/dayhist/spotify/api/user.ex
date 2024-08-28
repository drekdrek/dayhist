defmodule Dayhist.SpotifyAPI.User do
  alias Dayhist.SpotifyAPI.AccessToken
  require Logger

  def get(user_id) do
    access_token = AccessToken.get(user_id)

    case Req.get("https://api.spotify.com/v1/users/#{user_id}",
           headers: [{"Authorization", "Bearer #{access_token}"}]
         ) do
      {:ok, response} ->
        response.body

      {:error, reason} ->
        Logger.error("Failed to get user: #{reason}")
        nil
    end
  end
end
