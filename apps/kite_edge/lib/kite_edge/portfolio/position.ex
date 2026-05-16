defmodule KiteEdge.Portfolio.Position do
  @moduledoc "Intraday and carry-forward positions synchronized from Kite."
  use Ecto.Schema
  import Ecto.Changeset

  alias KiteEdge.Market.InstrumentMaster

  @type t :: %__MODULE__{}

  schema "positions_current" do
    belongs_to :instrument, InstrumentMaster, foreign_key: :instrument_id
    field :tradingsymbol, :string
    field :exchange, :string
    field :product, :string
    field :quantity, :integer
    field :average_price, :decimal
    field :last_price, :decimal
    field :pnl, :decimal
    field :m2m, :decimal
    field :buy_quantity, :integer
    field :buy_value, :decimal
    field :sell_quantity, :integer
    field :sell_value, :decimal
    field :segment, :string
    field :synced_at, :utc_datetime_usec
    timestamps(type: :utc_datetime_usec)
  end

  @required ~w(instrument_id tradingsymbol exchange product quantity average_price synced_at)a
  @optional ~w(last_price pnl m2m buy_quantity buy_value sell_quantity sell_value segment)a

  def changeset(record, attrs) do
    record
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> validate_inclusion(:product, ~w(CNC MIS NRML CO BO))
    |> unique_constraint([:tradingsymbol, :exchange, :product])
  end
end
