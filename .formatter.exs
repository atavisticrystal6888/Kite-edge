# Umbrella-wide Elixir formatter defaults.
# Applied across all four apps so formatting stays identical in CI (`mix format --check-formatted`).

[
  inputs: [
    "mix.exs",
    "config/*.exs",
    ".formatter.exs",
    "apps/*/mix.exs",
    "apps/*/{config,lib,test,priv/repo/migrations,priv/repo/seeds.exs}/**/*.{ex,exs}"
  ],
  line_length: 100,
  locals_without_parens: [
    # Ecto
    field: 2, field: 3,
    belongs_to: 2, belongs_to: 3,
    has_many: 2, has_many: 3,
    has_one: 2, has_one: 3,
    many_to_many: 2, many_to_many: 3,
    embeds_one: 2, embeds_one: 3, embeds_one: 4,
    embeds_many: 2, embeds_many: 3, embeds_many: 4,
    # Phoenix router / pipelines
    plug: 1, plug: 2,
    pipe_through: 1,
    get: 2, get: 3, get: 4,
    post: 2, post: 3, post: 4,
    put: 2, put: 3, put: 4,
    patch: 2, patch: 3, patch: 4,
    delete: 2, delete: 3, delete: 4,
    resources: 2, resources: 3, resources: 4,
    socket: 2, socket: 3,
    channel: 2, channel: 3,
    # Oban
    queue: 2
  ],
  import_deps: [:ecto, :ecto_sql, :phoenix, :plug, :oban],
  subdirectories: ["apps/*"]
]
