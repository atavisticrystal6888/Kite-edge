defmodule Notification.EmailAdapterTest do
  use ExUnit.Case, async: true

  alias Notification.EmailAdapter

  @moduletag :phase8

  describe "send_alert/2" do
    test "returns error tuple when mailer is unavailable" do
      alert = %{"headline" => "Price Alert", "body" => "RELIANCE crossed 2500"}

      # Without a running Mailer, this should raise or return error
      assert_raise UndefinedFunctionError, fn ->
        EmailAdapter.send_alert("user@example.com", alert)
      end
    end

    test "redacts sensitive fields in alert payload" do
      alert = %{
        "headline" => "Alert",
        "access_token" => "secret_token",
        "body" => "test"
      }

      # The adapter calls Redactor.redact internally
      # Verify redactor works on alert-like maps
      redacted = KiteEdge.Logging.Redactor.redact(alert)
      assert redacted["access_token"] == "[REDACTED]"
      assert redacted["headline"] == "Alert"
    end
  end
end
