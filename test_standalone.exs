# Standalone test for Redactor module (no DB required)
Code.require_file("apps/kite_edge/lib/kite_edge/logging/redactor.ex")

data = %{"access_token" => "secret123", "user" => "test"}
result = KiteEdge.Logging.Redactor.redact(data)
"[REDACTED]" = result["access_token"]
"test" = result["user"]
IO.puts("Redactor: basic redaction - PASS")

nested = %{"outer" => %{"api_secret" => "s3cret", "name" => "ok"}}
nested_result = KiteEdge.Logging.Redactor.redact(nested)
"[REDACTED]" = nested_result["outer"]["api_secret"]
"ok" = nested_result["outer"]["name"]
IO.puts("Redactor: nested redaction - PASS")

IO.puts("\nAll standalone Elixir tests PASS")
