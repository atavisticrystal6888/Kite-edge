import Config

config :kite_edge, KiteEdge.Repo,
  url: System.get_env("DATABASE_URL") || raise("DATABASE_URL required in prod"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE", "20")),
  ssl: true

config :logger, level: :info
