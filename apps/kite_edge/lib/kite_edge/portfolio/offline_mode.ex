defmodule KiteEdge.Portfolio.OfflineMode do
  @moduledoc """
  Offline-mode handling and stale-data freshness badges.

  Every query surface that reads from Redis or Postgres records a
  `:freshness` indicator: `:live`, `:stale`, or `:offline`. The dashboard
  renders a badge based on this value (see
  `dashboard/src/components/shared/FreshnessIndicator.tsx`).
  """

  @stale_seconds 60
  @offline_seconds 15 * 60

  @spec freshness(DateTime.t() | nil) :: :live | :stale | :offline
  def freshness(nil), do: :offline

  def freshness(%DateTime{} = synced_at) do
    age = DateTime.diff(DateTime.utc_now(), synced_at, :second)

    cond do
      age <= @stale_seconds -> :live
      age <= @offline_seconds -> :stale
      true -> :offline
    end
  end
end
