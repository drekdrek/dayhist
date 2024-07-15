# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :dayhist,
  ecto_repos: [Dayhist.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :dayhist, DayhistWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: DayhistWeb.ErrorHTML, json: DayhistWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Dayhist.PubSub,
  live_view: [signing_salt: "GqNVPkkC"]

config :ueberauth, Ueberauth,
  providers: [
    spotify:
      {Ueberauth.Strategy.Spotify, [default_scope: "playlist-read-private user-read-email"]}
  ]

config :ueberauth, Ueberauth.Strategy.Spotify.OAuth,
  client_id: System.get_env("SPOTIFY_CLIENT_ID"),
  client_secret: System.get_env("SPOTIFY_CLIENT_SECRET")

config :dayhist, Oban,
  engine: Oban.Engines.Basic,
  queues: [default: 10, spotify: 25],
  repo: Dayhist.Repo

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :dayhist, Dayhist.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  dayhist: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  dayhist: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

config :dayhist,
  client_id: System.get_env("SPOTIFY_CLIENT_ID"),
  client_secret: System.get_env("SPOTIFY_CLIENT_SECRET"),
  user_account_id: System.get_env("SPOTIFY_USER_ACCOUNT_ID")

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"