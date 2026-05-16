defmodule KiteEdge.Repo.Migrations.CreateCoreMarketTables do
  use Ecto.Migration

  def change do
    create table(:instrument_masters) do
      add :instrument_token, :bigint, null: false
      add :exchange, :string, size: 16, null: false
      add :tradingsymbol, :string, size: 64, null: false
      add :name, :string, size: 255
      add :segment, :string, size: 32
      add :instrument_type, :string, size: 16
      add :expiry, :date
      add :strike, :decimal, precision: 18, scale: 4
      add :tick_size, :decimal, precision: 10, scale: 4
      add :lot_size, :integer, default: 1
      add :isin, :string, size: 32
      add :sector, :string, size: 64
      add :market_cap_tier, :string, size: 16
      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:instrument_masters, [:instrument_token])
    create unique_index(:instrument_masters, [:exchange, :tradingsymbol])
    create index(:instrument_masters, [:sector])

    create table(:trading_calendars) do
      add :exchange, :string, size: 16, null: false
      add :trade_date, :date, null: false
      add :session_start, :time_usec, null: false
      add :session_end, :time_usec, null: false
      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:trading_calendars, [:exchange, :trade_date])

    create table(:holdings_current) do
      add :instrument_id, references(:instrument_masters, on_delete: :restrict), null: false
      add :tradingsymbol, :string, size: 64, null: false
      add :exchange, :string, size: 16, null: false
      add :quantity, :integer, null: false
      add :average_price, :decimal, precision: 18, scale: 4, null: false
      add :last_price, :decimal, precision: 18, scale: 4
      add :pnl, :decimal, precision: 18, scale: 4
      add :close_price, :decimal, precision: 18, scale: 4
      add :day_change, :decimal, precision: 18, scale: 4
      add :day_change_pct, :decimal, precision: 10, scale: 4
      add :collateral_quantity, :integer, default: 0
      add :collateral_type, :string, size: 16
      add :isin, :string, size: 32
      add :synced_at, :utc_datetime_usec, null: false
      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:holdings_current, [:tradingsymbol, :exchange])
    create index(:holdings_current, [:instrument_id])

    create table(:positions_current) do
      add :instrument_id, references(:instrument_masters, on_delete: :restrict), null: false
      add :tradingsymbol, :string, size: 64, null: false
      add :exchange, :string, size: 16, null: false
      add :product, :string, size: 16, null: false
      add :quantity, :integer, null: false
      add :average_price, :decimal, precision: 18, scale: 4, null: false
      add :last_price, :decimal, precision: 18, scale: 4
      add :pnl, :decimal, precision: 18, scale: 4
      add :m2m, :decimal, precision: 18, scale: 4
      add :buy_quantity, :integer, default: 0
      add :buy_value, :decimal, precision: 18, scale: 4, default: 0
      add :sell_quantity, :integer, default: 0
      add :sell_value, :decimal, precision: 18, scale: 4, default: 0
      add :segment, :string, size: 16
      add :synced_at, :utc_datetime_usec, null: false
      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:positions_current, [:tradingsymbol, :exchange, :product])

    create table(:trades) do
      add :kite_trade_id, :string, size: 64, null: false
      add :instrument_id, references(:instrument_masters, on_delete: :restrict), null: false
      add :tradingsymbol, :string, size: 64, null: false
      add :exchange, :string, size: 16, null: false
      add :transaction_type, :string, size: 8, null: false
      add :product, :string, size: 16, null: false
      add :quantity, :integer, null: false
      add :price, :decimal, precision: 18, scale: 4, null: false
      add :order_id, :string, size: 64
      add :exchange_order_id, :string, size: 64
      add :traded_at, :utc_datetime_usec, null: false
      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:trades, [:kite_trade_id])
    create index(:trades, [:instrument_id, :traded_at])
  end
end
