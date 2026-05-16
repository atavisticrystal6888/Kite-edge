defmodule KiteEdge.Settings.NotificationPreferencesTest do
  use ExUnit.Case, async: true

  alias KiteEdge.Settings.NotificationPreferences

  @moduletag :phase8

  describe "changeset/2" do
    test "valid changeset with required fields" do
      cs = NotificationPreferences.changeset(%NotificationPreferences{}, %{
        user_id: "user_123",
        in_app_enabled: true,
        email_enabled: false
      })
      assert cs.valid?
    end

    test "invalid without user_id" do
      cs = NotificationPreferences.changeset(%NotificationPreferences{}, %{
        in_app_enabled: true
      })
      refute cs.valid?
      assert {:user_id, _} = hd(cs.errors)
    end

    test "invalid email_address without @" do
      cs = NotificationPreferences.changeset(%NotificationPreferences{}, %{
        user_id: "user_123",
        email_address: "invalid-email"
      })
      refute cs.valid?
    end

    test "valid email_address with @" do
      cs = NotificationPreferences.changeset(%NotificationPreferences{}, %{
        user_id: "user_123",
        email_address: "user@example.com"
      })
      assert cs.valid?
    end

    test "default values applied" do
      cs = NotificationPreferences.changeset(%NotificationPreferences{}, %{
        user_id: "user_456"
      })
      assert cs.valid?
    end
  end
end
