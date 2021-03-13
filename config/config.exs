# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :stonepay,
  ecto_repos: [Stonepay.Repo]

# Configures the endpoint
config :stonepay, StonepayWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "pi/ygMqypSt95yJxgI6pMLqVpvj2X0PT4k9dGFcB/Ow2S/UOVdZYuyza+3bSXPjv",
  render_errors: [view: StonepayWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Stonepay.PubSub,
  live_view: [signing_salt: "ghfxykow"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
