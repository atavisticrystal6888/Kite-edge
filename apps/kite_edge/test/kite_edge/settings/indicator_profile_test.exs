defmodule KiteEdge.Settings.IndicatorProfileTest do
  use KiteEdge.DataCase, async: true

  alias KiteEdge.Settings.IndicatorProfile

  describe "changeset/2" do
    test "valid changeset" do
      attrs = %{user_id: 1, name: "default", params: %{"rsi_period" => 14}}
      changeset = IndicatorProfile.changeset(%IndicatorProfile{}, attrs)
      assert changeset.valid?
    end
  end
end
