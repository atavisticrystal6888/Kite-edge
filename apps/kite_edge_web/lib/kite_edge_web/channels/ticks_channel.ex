defmodule KiteEdgeWeb.TicksChannel do
  @moduledoc "Wired in Phase 3 (US1 live ticks). Placeholder join handler for Phase 2 boot."
  use KiteEdgeWeb, :channel

  @impl true
  def join("ticks:" <> _token, _params, socket), do: {:ok, socket}
end
