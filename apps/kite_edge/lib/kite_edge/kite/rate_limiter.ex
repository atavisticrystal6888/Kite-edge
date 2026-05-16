defmodule KiteEdge.Kite.RateLimiter do
  @moduledoc """
  Token-bucket rate limiter honoring the 3 req/sec Kite API cap
  (Constitution Principle 1, MUST). Callers pass through `acquire/0`
  which blocks until a token is available.

  Bucket is an in-memory GenServer; process isolation per node is fine
  because a single gateway terminates all outbound Kite traffic.
  """
  use GenServer

  @default_rate_per_second 3
  @refill_interval_ms 1_000

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc "Blocks the caller until a request token is available."
  def acquire, do: GenServer.call(__MODULE__, :acquire, :infinity)

  @impl true
  def init(opts) do
    rate =
      Keyword.get(opts, :rate_per_second) ||
        Application.get_env(:kite_edge, :kite_rate_limit_per_second, @default_rate_per_second)

    schedule_refill()
    {:ok, %{tokens: rate, capacity: rate, waiters: :queue.new()}}
  end

  @impl true
  def handle_call(:acquire, from, %{tokens: 0, waiters: q} = s) do
    {:noreply, %{s | waiters: :queue.in(from, q)}}
  end

  def handle_call(:acquire, _from, %{tokens: t} = s) do
    {:reply, :ok, %{s | tokens: t - 1}}
  end

  @impl true
  def handle_info(:refill, %{tokens: existing, capacity: cap, waiters: q} = s) do
    available = min(existing + cap, cap)
    {tokens, q2} = drain(available, q)
    schedule_refill()
    {:noreply, %{s | tokens: tokens, waiters: q2}}
  end

  defp drain(0, q), do: {0, q}

  defp drain(n, q) do
    case :queue.out(q) do
      {{:value, from}, q2} ->
        GenServer.reply(from, :ok)
        drain(n - 1, q2)

      {:empty, _} ->
        {n, q}
    end
  end

  defp schedule_refill, do: Process.send_after(self(), :refill, @refill_interval_ms)
end
