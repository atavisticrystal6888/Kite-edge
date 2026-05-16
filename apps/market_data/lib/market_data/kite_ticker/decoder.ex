defmodule MarketData.KiteTicker.Decoder do
  @moduledoc """
  Decodes KiteTicker binary WebSocket frames.

  Kite sends packets as:
    - 2-byte big-endian count of packets
    - For each packet:
      - 2-byte big-endian length
      - Payload, length-dependent:
        * 8 bytes  -> LTP mode   (token + last_price)
        * 44 bytes -> Quote mode
        * 184 bytes -> Full mode (order book depth)

  Prices are sent as paise (×100). We divide by 100 at the edge so the
  rest of the system works with rupees.
  """

  @spec decode(binary()) :: {:ok, [map()]} | {:error, term()}
  def decode(<<count::unsigned-big-16, rest::binary>>) do
    decode_packets(count, rest, [])
  end

  def decode(_), do: {:error, :invalid_frame}

  defp decode_packets(0, _rest, acc), do: {:ok, Enum.reverse(acc)}

  defp decode_packets(n, <<len::unsigned-big-16, payload::binary-size(len), rest::binary>>, acc) do
    decode_packets(n - 1, rest, [decode_packet(payload) | acc])
  end

  defp decode_packets(_n, _bin, _acc), do: {:error, :truncated}

  # LTP mode
  defp decode_packet(<<token::unsigned-big-32, ltp::unsigned-big-32>>) do
    %{instrument_token: token, last_price: ltp / 100.0, mode: :ltp}
  end

  # Quote mode
  defp decode_packet(<<token::unsigned-big-32, ltp::unsigned-big-32, rest::binary-size(36)>>) do
    <<
      last_qty::unsigned-big-32,
      avg_price::unsigned-big-32,
      volume::unsigned-big-32,
      buy_qty::unsigned-big-32,
      sell_qty::unsigned-big-32,
      open::unsigned-big-32,
      high::unsigned-big-32,
      low::unsigned-big-32,
      close::unsigned-big-32
    >> = rest

    %{
      instrument_token: token,
      last_price: ltp / 100.0,
      last_quantity: last_qty,
      average_price: avg_price / 100.0,
      volume: volume,
      buy_quantity: buy_qty,
      sell_quantity: sell_qty,
      open: open / 100.0,
      high: high / 100.0,
      low: low / 100.0,
      close: close / 100.0,
      mode: :quote
    }
  end

  defp decode_packet(bin), do: %{raw: bin, mode: :unknown}
end
