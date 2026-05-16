import Config

config :kite_edge, KiteEdge.Repo,
  url: System.get_env("DATABASE_URL", "ecto://postgres:postgres@localhost:5432/kiteedge_test"),
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

config :logger, level: :warning
