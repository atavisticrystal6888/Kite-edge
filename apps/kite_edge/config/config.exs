import Config

# Ecto repository configuration for the core kite_edge application.
# The umbrella's root config imports this file.

config :kite_edge,
  ecto_repos: [KiteEdge.Repo],
  generators: [timestamp_type: :utc_datetime_usec, binary_id: false]

config :kite_edge, KiteEdge.Repo,
  migration_timestamps: [type: :utc_datetime_usec],
  migration_primary_key: [name: :id, type: :bigserial],
  migration_foreign_key: [column: :id, type: :bigint],
  migration_lock: :pg_advisory_lock,
  priv: "priv/repo",
  telemetry_prefix: [:kite_edge, :repo]

# Oban background jobs: holdings/trade/candle sync, scheduled reports.
config :kite_edge, Oban,
  repo: KiteEdge.Repo,
  engine: Oban.Engines.Basic,
  queues: [
    kite_sync: 4,
    backfill: 2,
    analytics: 4,
    reports: 2,
    alerts: 4,
    default: 10
  ],
  plugins: [
    {Oban.Plugins.Pruner, max_age: 60 * 60 * 24 * 7},
    {Oban.Plugins.Cron,
     crontab: [
       # Every market day pre-open: refresh instrument master.
       {"15 3 * * 1-5", KiteEdge.Sync.InstrumentMasterSync},
       # Nightly historical candle backfill sweep (IST ~ 00:30).
       {"0 19 * * *", KiteEdge.Sync.HistoricalBackfill},
       # Nightly forecast retrain handoff to Python pipeline.
       {"30 19 * * *", KiteEdge.Analytics.ForecastRetrainTrigger}
     ]}
  ]

# Jason as the default JSON library for Ecto types.
config :kite_edge, :json_library, Jason
