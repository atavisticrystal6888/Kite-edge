defmodule KiteEdge.Market.InstrumentQuery do
  @moduledoc "T074a: Instrument lookup, quote, and OHLCV query service."

  alias KiteEdge.Repo
  alias KiteEdge.Market.InstrumentMaster
  import Ecto.Query

  def search(query, opts \\ []) do
    exchange = Keyword.get(opts, :exchange)
    limit = min(Keyword.get(opts, :limit, 20), 100)

    q =
      from(i in InstrumentMaster,
        where: ilike(i.tradingsymbol, ^"%#{query}%"),
        limit: ^limit,
        order_by: [asc: i.tradingsymbol]
      )

    q = if exchange, do: where(q, [i], i.exchange == ^exchange), else: q

    Repo.all(q)
    |> Enum.map(&serialize/1)
  end

  def quote(symbol, exchange \\ "NSE") do
    case Repo.get_by(InstrumentMaster, tradingsymbol: symbol, exchange: exchange) do
      nil ->
        {:error, :not_found}

      inst ->
        # Enrich with cached LTP from Redis
        ltp = cached_ltp(inst.instrument_token)
        {:ok, %{
          symbol: inst.tradingsymbol,
          exchange: inst.exchange,
          last_price: ltp,
          instrument_type: inst.instrument_type,
          sector: inst.sector
        }}
    end
  end

  def ohlcv(symbol, timeframe, from_dt, to_dt, exchange \\ "NSE") do
    # In production this queries the candles table
    # For now return empty candles
    {:ok, %{
      instrument: %{symbol: symbol, exchange: exchange},
      timeframe: timeframe,
      candles: []
    }}
  end

  defp cached_ltp(token) do
    case Cachex.get(:kite_edge_cache, "ltp:#{token}") do
      {:ok, val} when not is_nil(val) -> val
      _ -> nil
    end
  end

  defp serialize(inst) do
    %{
      symbol: inst.tradingsymbol,
      name: inst.name,
      exchange: inst.exchange,
      instrument_type: inst.instrument_type,
      sector: inst.sector
    }
  end
end
