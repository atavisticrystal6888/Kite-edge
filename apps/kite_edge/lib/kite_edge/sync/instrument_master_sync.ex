defmodule KiteEdge.Sync.InstrumentMasterSync do
  @moduledoc """
  Refreshes the instrument master CSV from Kite once per trading day.

  Runs as an Oban cron job (see `apps/kite_edge/config/config.exs`).
  """
  use Oban.Worker, queue: :kite_sync, max_attempts: 3

  alias KiteEdge.Kite.Client
  alias KiteEdge.Market.InstrumentMaster
  alias KiteEdge.Repo
  require Logger

  @impl Oban.Worker
  def perform(_job), do: run()

  def run do
    Logger.info("instrument master sync starting")

    with {:ok, csv} <- fetch_dump() do
      csv
      |> parse_csv()
      |> Enum.each(&upsert/1)
    end
  end

  defp fetch_dump do
    # Public instruments CSV endpoint. Uses Finch directly so it does not
    # consume a Kite rate-limiter token (it's an unauthenticated static dump).
    case Finch.build(:get, "https://api.kite.trade/instruments") |> Finch.request(KiteEdge.Finch) do
      {:ok, %Finch.Response{status: 200, body: body}} -> {:ok, body}
      other -> {:error, other}
    end
  end

  defp parse_csv(body) do
    [_header | rows] = String.split(body, "\n", trim: true)

    Enum.map(rows, fn row ->
      [token, _exchange_token, tradingsymbol, name, _last_price, expiry, strike,
       tick_size, lot_size, instrument_type, segment, exchange] = String.split(row, ",", parts: 12)

      %{
        instrument_token: String.to_integer(token),
        tradingsymbol: tradingsymbol,
        name: name,
        expiry: parse_date(expiry),
        strike: parse_decimal(strike),
        tick_size: parse_decimal(tick_size),
        lot_size: parse_int(lot_size),
        instrument_type: instrument_type,
        segment: segment,
        exchange: exchange
      }
    end)
  end

  defp upsert(%{instrument_token: token} = attrs) do
    case Repo.get_by(InstrumentMaster, instrument_token: token) do
      nil -> %InstrumentMaster{} |> InstrumentMaster.changeset(attrs) |> Repo.insert!()
      existing -> existing |> InstrumentMaster.changeset(attrs) |> Repo.update!()
    end
  end

  defp parse_date(""), do: nil
  defp parse_date(s), do: Date.from_iso8601!(s)
  defp parse_decimal(""), do: nil
  defp parse_decimal(s), do: Decimal.new(s)
  defp parse_int(""), do: nil
  defp parse_int(s), do: String.to_integer(s)
end
