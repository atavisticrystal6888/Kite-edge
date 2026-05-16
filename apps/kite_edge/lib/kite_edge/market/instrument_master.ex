defmodule KiteEdge.Market.InstrumentMaster do
  @moduledoc "Instrument master record mirrored from the Kite instruments dump."
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  schema "instrument_masters" do
    field :instrument_token, :integer
    field :exchange, :string
    field :tradingsymbol, :string
    field :name, :string
    field :segment, :string
    field :instrument_type, :string
    field :expiry, :date
    field :strike, :decimal
    field :tick_size, :decimal
    field :lot_size, :integer
    field :isin, :string
    field :sector, :string
    field :market_cap_tier, :string
    timestamps(type: :utc_datetime_usec)
  end

  @required ~w(instrument_token exchange tradingsymbol)a
  @optional ~w(name segment instrument_type expiry strike tick_size lot_size isin sector market_cap_tier)a

  def changeset(record, attrs) do
    record
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> unique_constraint(:instrument_token)
    |> unique_constraint([:exchange, :tradingsymbol])
  end
end
