import Config

config :kite_edge, KiteEdge.Repo,
  url: System.get_env("DATABASE_URL", "ecto://kiteedge:kiteedge@localhost:5432/kiteedge_dev"),
  pool_size: 10,
  show_sensitive_data_on_connection_error: true,
  stacktrace: true
