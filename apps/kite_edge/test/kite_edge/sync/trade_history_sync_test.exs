defmodule KiteEdge.Sync.TradeHistorySyncTest do
  use ExUnit.Case, async: true

  alias KiteEdge.Sync.TradeHistorySync

  @moduletag :phase7

  describe "module structure" do
    test "trade_history_sync module exists" do
      assert Code.ensure_loaded?(TradeHistorySync)
    end

    test "has sync/2 function" do
      assert function_exported?(TradeHistorySync, :sync, 2)
    end
  end
end
