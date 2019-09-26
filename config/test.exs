use Mix.Config

# Configure your database
# config :frameworks_shootout, FrameworksShootout.Repo,
#   username: "postgres",
#   password: "postgres",
#   database: "frameworks_shootout_test",
#   hostname: "localhost",
#   pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :frameworks_shootout, FrameworksShootoutWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
