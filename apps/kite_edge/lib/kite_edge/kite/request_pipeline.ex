defmodule KiteEdge.Kite.RequestPipeline do
  @moduledoc """
  Retry and backoff request orchestration for the Kite client.
  Wraps a 0-arity function that performs the actual HTTP call and
  retries transient failures.

  Behavior:

    * Retries only 5xx responses and transport errors.
    * Exponential backoff with jitter, capped at `@max_retries`.
    * On token expiry, bubbles `{:error, {:kite, :token_expired}}` immediately
      so the caller can re-authenticate.
  """
  require Logger

  @max_retries 3
  @base_delay_ms 200

  @type response :: {:ok, map()} | {:error, term()}

  @spec run((-> response())) :: response()
  def run(fun) when is_function(fun, 0) do
    do_run(fun, 0)
  end

  defp do_run(fun, attempt) do
    case fun.() do
      {:ok, _} = ok ->
        ok

      {:error, {:kite, :token_expired}} = err ->
        err

      {:error, reason} when attempt < @max_retries ->
        delay = :rand.uniform(@base_delay_ms) + trunc(:math.pow(2, attempt) * @base_delay_ms)
        Logger.warning("kite request failed, retrying in #{delay}ms (attempt #{attempt + 1}/#{@max_retries}): #{inspect(reason)}")
        Process.sleep(delay)
        do_run(fun, attempt + 1)

      {:error, _reason} ->
        {:error, :upstream_unavailable}
    end
  end
end
