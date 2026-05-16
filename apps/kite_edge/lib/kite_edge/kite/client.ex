defmodule KiteEdge.Kite.Client do
  @moduledoc """
  Thin Tesla-based wrapper over the Kite Connect v3 REST API.

  Responsibilities:

    * Acquire a rate-limiter token before every outbound call (Principle 1).
    * Inject `X-Kite-Version: 3` and `Authorization: token <api_key>:<access_token>` headers.
    * Surface Kite error envelopes as `{:error, {:kite, reason}}`.
    * Defer retry/backoff to `KiteEdge.Kite.RequestPipeline`.

  Access tokens are NEVER stored server-side outside
  `KiteEdge.Kite.SessionStore` (Principle 7).
  """
  use Tesla, only: []

  alias KiteEdge.Kite.{RateLimiter, RequestPipeline}

  @base_url "https://api.kite.trade"

  plug Tesla.Middleware.BaseUrl, @base_url
  plug Tesla.Middleware.Headers, [{"x-kite-version", "3"}]
  plug Tesla.Middleware.JSON

  @spec get(String.t(), keyword()) :: {:ok, map()} | {:error, term()}
  def get(path, opts) when is_binary(path) and is_list(opts) do
    RequestPipeline.run(fn ->
      :ok = RateLimiter.acquire()

      headers = auth_headers(opts)

      case Tesla.get(__MODULE__, path, headers: headers) do
        {:ok, %Tesla.Env{status: 200, body: body}} ->
          {:ok, body}

        {:ok, %Tesla.Env{status: 403, body: %{"error_type" => "TokenException"}}} ->
          {:error, {:kite, :token_expired}}

        {:ok, %Tesla.Env{status: status, body: body}} when status >= 500 ->
          {:error, {:upstream, status, body}}

        {:ok, %Tesla.Env{status: status, body: body}} ->
          {:error, {:kite, kite_reason(body, status)}}

        {:error, reason} ->
          {:error, reason}
      end
    end)
  end

  @spec post(String.t(), map() | keyword(), keyword()) :: {:ok, map()} | {:error, term()}
  def post(path, body, opts) when is_binary(path) and is_list(opts) do
    RequestPipeline.run(fn ->
      :ok = RateLimiter.acquire()
      headers = auth_headers(opts)

      case Tesla.post(__MODULE__, path, body, headers: headers) do
        {:ok, %Tesla.Env{status: status, body: resp_body}} when status in 200..299 ->
          {:ok, resp_body}

        {:ok, %Tesla.Env{status: status, body: resp_body}} ->
          {:error, {:kite, kite_reason(resp_body, status)}}

        {:error, reason} ->
          {:error, reason}
      end
    end)
  end

  defp auth_headers(opts) do
    api_key = Application.get_env(:kite_edge, :kite_api_key, System.get_env("KITE_API_KEY", ""))
    token = Keyword.fetch!(opts, :access_token)
    [{"authorization", "token #{api_key}:#{token}"}]
  end

  defp kite_reason(%{"error_type" => t}, _), do: String.to_existing_atom(Macro.underscore(t))
  defp kite_reason(_, status), do: {:http, status}
end
