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

  host = System.get_env("PHX_HOST", "localhost")
  port = String.to_integer(System.get_env("PHX_PORT", "4000"))

  config :kite_edge_web, KiteEdgeWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [ip: {0, 0, 0, 0}, port: port],
    secret_key_base: secret_key_base,
    server: true

  # CORS origins — comma-separated list from env
  cors_origins =
    System.get_env("CORS_ORIGINS", "http://localhost:5173")
    |> String.split(",", trim: true)
    |> Enum.map(&String.trim/1)

  config :kite_edge_web, :cors_origins, cors_origins

  # Analytics engine URL
  config :kite_edge_web, :analytics_engine_url,
    System.get_env("ANALYTICS_ENGINE_URL", "http://analytics_engine:8001")

  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      """

  config :kite_edge, KiteEdge.Repo,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE", "20")),
    ssl: true

  # Redis
  config :kite_edge, :redis_url, System.get_env("REDIS_URL", "redis://redis:6379/0")

  # Sentry error tracking
  if dsn = System.get_env("SENTRY_DSN") do
    config :sentry,
      dsn: dsn,
      environment_name: :prod,
      enable_source_code_context: true,
      root_source_code_paths: [File.cwd!()]
  end
end
