defmodule KiteEdge.Kite.ErrorMapper do
  @moduledoc "T194: Graceful Kite API error mapping and user-safe failures."

  def map_error({:kite, :token_expired}), do: {:unauthorized, "KITE_SESSION_EXPIRED", "Broker authorization expired. Re-authentication is required.", false}
  def map_error({:kite, :input_exception}), do: {:bad_request, "KITE_INPUT_ERROR", "Invalid request parameters.", false}
  def map_error({:kite, :data_exception}), do: {:service_unavailable, "KITE_DATA_ERROR", "Broker returned invalid data. Please retry.", true}
  def map_error({:kite, :network_exception}), do: {:service_unavailable, "KITE_NETWORK_ERROR", "Broker network error. Please retry.", true}
  def map_error({:kite, :order_exception}), do: {:bad_request, "KITE_ORDER_ERROR", "Broker order error.", false}
  def map_error({:upstream, status, _body}), do: {:bad_gateway, "UPSTREAM_ERROR", "Upstream service returned #{status}.", true}
  def map_error({:rate_limited, _}), do: {:too_many_requests, "RATE_LIMITED", "Rate limit exceeded. Please wait.", true}
  def map_error(:timeout), do: {:gateway_timeout, "TIMEOUT", "Request timed out.", true}
  def map_error(_other), do: {:internal_server_error, "INTERNAL_ERROR", "An unexpected error occurred.", false}

  def to_json_error(reason) do
    {_status, code, message, retryable} = map_error(reason)
    %{
      errors: [%{code: code, message: message, retryable: retryable}],
      data: nil,
      meta: %{generated_at: DateTime.utc_now() |> DateTime.to_iso8601(), source_mode: "offline"}
    }
  end
end
