defmodule KiteEdge.Sync.HoldingsSyncTest do
  @moduledoc """
  T018: Holdings + positions sync integration tests.

  Uses the Tesla mock to serve a fake Kite portfolio and asserts that rows
  land in the database idempotently. Re-running sync on the same payload
  must not create duplicates.
  """
  use KiteEdge.DataCase, async: false

  alias KiteEdge.Portfolio.Holding
  alias KiteEdge.Sync.HoldingsSync

  setup do
    Tesla.Mock.mock_global(fn
      %{url: "https://api.kite.trade/portfolio/holdings"} ->
        %Tesla.Env{
          status: 200,
          body: %{
            "status" => "success",
            "data" => [
              %{
                "tradingsymbol" => "RELIANCE",
                "exchange" => "NSE",
                "instrument_token" => 738_561,
                "quantity" => 10,
                "average_price" => 2400.50,
                "last_price" => 2500.0,
                "pnl" => 995.0
              }
            ]
          }
        }

      %{url: "https://api.kite.trade/portfolio/positions"} ->
        %Tesla.Env{status: 200, body: %{"status" => "success", "data" => %{"net" => [], "day" => []}}}
    end)

    :ok
  end

  test "sync inserts holdings on first run and updates on second run" do
    assert :ok = HoldingsSync.sync(access_token: "t0k3n")
    assert [h1] = Repo.all(Holding)
    assert h1.tradingsymbol == "RELIANCE"

    assert :ok = HoldingsSync.sync(access_token: "t0k3n")
    assert [h2] = Repo.all(Holding)
    assert h2.id == h1.id, "expected upsert, got duplicate"
  end
end
