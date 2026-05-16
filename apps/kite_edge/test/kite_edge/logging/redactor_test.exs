defmodule KiteEdge.Logging.RedactorTest do
  use ExUnit.Case, async: true

  alias KiteEdge.Logging.Redactor

  describe "redact/1" do
    test "redacts access_token" do
      data = %{"access_token" => "secret123", "user" => "test"}
      assert %{"access_token" => "[REDACTED]", "user" => "test"} = Redactor.redact(data)
    end

    test "redacts nested keys" do
      data = %{"outer" => %{"api_secret" => "s3cret"}}
      assert %{"outer" => %{"api_secret" => "[REDACTED]"}} = Redactor.redact(data)
    end
  end
end
