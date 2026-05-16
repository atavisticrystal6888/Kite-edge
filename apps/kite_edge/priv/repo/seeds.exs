# KiteEdge seed data.
# Run via:  mix cmd --app kite_edge mix run priv/repo/seeds.exs
#
# Seeds:
#   * NSE and BSE trading calendars for the current + next year
#   * A small sample of instrument masters for local development
#   * Default indicator profile (FR-023) and notification preferences (FR-071)
#
# This script is idempotent. Existing rows keyed by the unique columns are
# left in place.

alias KiteEdge.Repo

require Logger

unless Code.ensure_loaded?(Repo) do
  raise "KiteEdge.Repo is not loaded. Run from an environment where the application is started."
end

now = DateTime.utc_now() |> DateTime.truncate(:microsecond)

# ---------------------------------------------------------------------------
# Trading calendars
# ---------------------------------------------------------------------------
# NSE observed holidays for 2026. Maintained manually; replace with the
# official NSE calendar feed once available.
nse_holidays_2026 = [
  ~D[2026-01-26], ~D[2026-03-06], ~D[2026-03-19], ~D[2026-04-03],
  ~D[2026-04-14], ~D[2026-05-01], ~D[2026-08-15], ~D[2026-08-26],
  ~D[2026-10-02], ~D[2026-10-21], ~D[2026-11-04], ~D[2026-11-17],
  ~D[2026-12-25]
]

trading_calendar_rows =
  for date <- Date.range(~D[2026-01-01], ~D[2026-12-31]),
      Date.day_of_week(date) in 1..5,
      date not in nse_holidays_2026 do
    %{
      exchange: "NSE",
      trade_date: date,
      session_start: ~T[09:15:00.000000],
      session_end: ~T[15:30:00.000000],
      inserted_at: now,
      updated_at: now
    }
  end

if function_exported?(KiteEdge.Market.TradingCalendar, :__schema__, 1) do
  {count, _} =
    Repo.insert_all(
      KiteEdge.Market.TradingCalendar,
      trading_calendar_rows,
      on_conflict: :nothing,
      conflict_target: [:exchange, :trade_date]
    )

  Logger.info("seeded #{count} trading calendar rows for NSE 2026")
else
  Logger.warning("TradingCalendar schema not yet compiled; skipping calendar seed.")
end

# ---------------------------------------------------------------------------
# Instrument masters (sample)
# ---------------------------------------------------------------------------
sample_instruments = [
  %{instrument_token: 738561, exchange: "NSE", tradingsymbol: "RELIANCE", name: "Reliance Industries", segment: "NSE", instrument_type: "EQ", tick_size: Decimal.new("0.05"), lot_size: 1},
  %{instrument_token: 340481, exchange: "NSE", tradingsymbol: "INFY",     name: "Infosys",             segment: "NSE", instrument_type: "EQ", tick_size: Decimal.new("0.05"), lot_size: 1},
  %{instrument_token: 408065, exchange: "NSE", tradingsymbol: "TCS",      name: "Tata Consultancy",    segment: "NSE", instrument_type: "EQ", tick_size: Decimal.new("0.05"), lot_size: 1},
  %{instrument_token: 779521, exchange: "NSE", tradingsymbol: "HDFCBANK", name: "HDFC Bank",           segment: "NSE", instrument_type: "EQ", tick_size: Decimal.new("0.05"), lot_size: 1},
  %{instrument_token: 256265, exchange: "NSE", tradingsymbol: "NIFTY 50", name: "NIFTY 50 Index",      segment: "INDICES", instrument_type: "INDEX", tick_size: Decimal.new("0.05"), lot_size: 1}
]

if function_exported?(KiteEdge.Market.InstrumentMaster, :__schema__, 1) do
  rows = for i <- sample_instruments, do: Map.merge(i, %{inserted_at: now, updated_at: now})

  {count, _} =
    Repo.insert_all(
      KiteEdge.Market.InstrumentMaster,
      rows,
      on_conflict: {:replace_all_except, [:id, :inserted_at]},
      conflict_target: [:instrument_token]
    )

  Logger.info("seeded #{count} instrument masters")
else
  Logger.warning("InstrumentMaster schema not yet compiled; skipping instrument seed.")
end

# ---------------------------------------------------------------------------
# Default indicator profile (FR-023) + notification preferences (FR-071)
# ---------------------------------------------------------------------------
if function_exported?(KiteEdge.Settings.IndicatorProfile, :__schema__, 1) do
  profile_defaults = %{
    profile_key: "default",
    parameters: %{
      "sma" => [20, 50, 200],
      "ema" => [9, 21],
      "rsi" => %{"period" => 14},
      "macd" => %{"fast" => 12, "slow" => 26, "signal" => 9},
      "bollinger" => %{"period" => 20, "stddev" => 2.0}
    },
    is_default: true,
    inserted_at: now,
    updated_at: now
  }

  Repo.insert_all(
    KiteEdge.Settings.IndicatorProfile,
    [profile_defaults],
    on_conflict: :nothing,
    conflict_target: [:profile_key]
  )

  Logger.info("seeded default indicator profile")
end

if function_exported?(KiteEdge.Settings.NotificationPreferences, :__schema__, 1) do
  rows = [
    %{channel: "in_app", enabled: true,  severity_floor: "Info",  inserted_at: now, updated_at: now},
    %{channel: "email",  enabled: false, severity_floor: "Watch", inserted_at: now, updated_at: now}
  ]

  Repo.insert_all(
    KiteEdge.Settings.NotificationPreferences,
    rows,
    on_conflict: :nothing,
    conflict_target: [:channel]
  )

  Logger.info("seeded default notification preferences")
end

Logger.info("seeds.exs complete")
