defmodule KiteEdge.Logging.Redactor do
  @moduledoc "T192: Structured-log token redaction."

  @sensitive_keys ~w(access_token api_secret api_key password token authorization cookie secret private_key refresh_token session_id bearer)

  def redact(data) when is_map(data) do
    Map.new(data, fn {k, v} ->
      key_str = to_string(k)
      if Enum.any?(@sensitive_keys, &(String.contains?(String.downcase(key_str), &1))) do
        {k, "[REDACTED]"}
      else
        {k, redact(v)}
      end
    end)
  end

  def redact(data) when is_list(data), do: Enum.map(data, &redact/1)
  def redact(data), do: data
end
