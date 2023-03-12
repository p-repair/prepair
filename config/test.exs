import Config

# Configure your database
#
# We don't run a server during test. If one is required,
# you can enable the server option below.
config :prepair_landing_page, PrepairLandingPageWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base:
    "yawL/JaqMcaT7WsXVxyGAlYX9IVkpbYmqus9RIKGqOqyWf/Yyo8mU8kWWC1yMd5r",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
