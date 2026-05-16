defmodule KiteEdgeWeb.AnalyticsChannel do
  @moduledoc "Wired in Phase 5+ for long-running analytics progress. Placeholder for Phase 2."
  use KiteEdgeWeb, :channel

  @impl true
  def join("analytics:progress", _params, socket), do: {:ok, socket}
end
