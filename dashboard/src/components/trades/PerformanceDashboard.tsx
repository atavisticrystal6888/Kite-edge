/** T148: Trade performance dashboard. */
export function PerformanceDashboard({
  metrics,
}: {
  metrics: { total_trades: number; win_rate: number; expectancy: number; total_pnl: number; profit_factor: number | null }
}) {
  return (
    <div className="grid grid-cols-2 md:grid-cols-5 gap-3" data-testid="trade-performance">
      <Card label="Total Trades" value={metrics.total_trades.toString()} />
      <Card label="Win Rate" value={`${metrics.win_rate.toFixed(1)}%`} />
      <Card label="Expectancy" value={metrics.expectancy.toFixed(2)} />
      <Card label="Total P&L" value={metrics.total_pnl.toFixed(2)} tone={metrics.total_pnl >= 0 ? 'pos' : 'neg'} />
      <Card label="Profit Factor" value={metrics.profit_factor?.toFixed(2) ?? '—'} />
    </div>
  )
}

function Card({ label, value, tone }: { label: string; value: string; tone?: 'pos' | 'neg' }) {
  return (
    <div className="border rounded-lg p-3 text-center">
      <div className="text-xs text-slate-500">{label}</div>
      <div className={`text-lg font-semibold ${tone === 'pos' ? 'text-green-600' : tone === 'neg' ? 'text-red-600' : ''}`}>
        {value}
      </div>
    </div>
  )
}
