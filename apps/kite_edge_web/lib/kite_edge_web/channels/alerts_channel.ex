defmodule KiteEdgeWeb.AlertsChannel do
  @moduledoc "Wired in Phase 8 (US26). Placeholder join handler for Phase 2 boot."
  use KiteEdgeWeb, :channel

  @impl true
  def join("alerts:user", _params, socket), do: {:ok, socket}
end
