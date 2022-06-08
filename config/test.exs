import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :metaspexet, Metaspexet.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "metaspexet_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :metaspexet, MetaspexetWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "SIPsTZy71j+Pt089qJGuiu4YIXVPrONzkNNqAKxq4CNyZpd3UnhE2s5p4e9a7hP4",
  server: false

# In test we don't send emails.
config :metaspexet, Metaspexet.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
