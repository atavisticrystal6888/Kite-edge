import Config

config :kite_edge_web, KiteEdgeWeb.Endpoint,
  url: [host: "localhost"],
  http: [ip: {0, 0, 0, 0}, port: 4000],
  secret_key_base:
    System.get_env("SECRET_KEY_BASE",
      "oZrZKAqz3uYtOa0IbcmL8wZ3llzuD0hv6zRC2qW8t1MLlQWRlSHtGtC2Ug0JgNgH"),
  render_errors: [formats: [json: KiteEdgeWeb.ErrorJSON], layout: false],
  pubsub_server: KiteEdge.PubSub,
  live_view: [signing_salt: "kiteedge-live"]

config :phoenix, :json_library, Jason
