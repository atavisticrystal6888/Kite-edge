import Config

# Runtime configuration is read when the application starts.
# This file is read after compilation and supports env vars.

if config_env() == :prod do
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  config :kite_edge_web, KiteEdgeWeb.Endpoint,
    secret_key_base: secret_key_base

  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      """

  config :kite_edge, KiteEdge.Repo,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE", "20")),
    ssl: true
end
