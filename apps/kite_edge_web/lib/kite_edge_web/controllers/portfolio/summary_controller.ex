defmodule KiteEdgeWeb.Portfolio.SummaryController do
  @moduledoc "GET /api/v1/portfolio/summary — US4."
  use KiteEdgeWeb, :controller

  alias KiteEdge.Portfolio.{
    Composition,
    ConcentrationRisk,
    HoldingsQuery,
    MarketCapDistribution,
    Summary
  }

  def show(conn, _params) do
    %{data: holdings, freshness: freshness, synced_at: synced_at} = HoldingsQuery.list()
    base = Summary.build(holdings)

    payload =
      base
      |> Map.put(:sector_allocation, Composition.by_sector(holdings))
      |> Map.put(:market_cap_distribution, MarketCapDistribution.aggregate(holdings))
      |> Map.put(:concentration, ConcentrationRisk.analyze(holdings))
      |> Map.put(:freshness, freshness)
      |> Map.put(:synced_at, synced_at && DateTime.to_iso8601(synced_at))

    json(conn, payload)
  end
end
