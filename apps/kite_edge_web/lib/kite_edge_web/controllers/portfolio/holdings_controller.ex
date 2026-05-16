defmodule KiteEdgeWeb.Portfolio.HoldingsController do
  @moduledoc "GET /api/v1/portfolio/holdings — US1."
  use KiteEdgeWeb, :controller

  alias KiteEdge.Portfolio.HoldingsQuery

  def index(conn, _params) do
    %{data: rows, freshness: freshness, synced_at: synced_at} = HoldingsQuery.list()

    json(conn, %{
      data: rows,
      meta: %{
        freshness: freshness,
        synced_at: synced_at && DateTime.to_iso8601(synced_at)
      }
    })
  end
end
