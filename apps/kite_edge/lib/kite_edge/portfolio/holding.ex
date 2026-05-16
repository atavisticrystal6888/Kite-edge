defmodule KiteEdge.Portfolio.Holding do
  @moduledoc "Long-term holdings synchronized from Kite (`/portfolio/holdings`)."
  use Ecto.Schema
  import Ecto.Changeset

  alias KiteEdge.Market.InstrumentMaster

  @type t :: %__MODULE__{}

  schema "holdings_current" do
    belongs_to :instrument, InstrumentMaster, foreign_key: :instrument_id
    field :tradingsymbol, :string
    field :exchange, :string
    field :quantity, :integer
    field :average_price, :decimal
    field :last_price, :decimal
    field :pnl, :decimal
    field :close_price, :decimal
    field :day_change, :decimal
    field :day_change_pct, :decimal
    field :collateral_quantity, :integer
    field :collateral_type, :string
    field :isin, :string
    field :synced_at, :utc_datetime_usec
    timestamps(type: :utc_datetime_usec)
  end

  @required ~w(instrument_id tradingsymbol exchange quantity average_price synced_at)a
  @optional ~w(last_price pnl close_price day_change day_change_pct collateral_quantity collateral_type isin)a

  def changeset(record, attrs) do
    record
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> validate_number(:quantity, greater_than_or_equal_to: 0)
    |> unique_constraint([:tradingsymbol, :exchange])
  end
end
