/** T108: Drawdown chart. */
import { AreaChart, Area, XAxis, YAxis, ResponsiveContainer, Tooltip } from 'recharts'

export function DrawdownChart({ data }: { data: { date: string; drawdown_pct: number }[] }) {
  return (
    <div className="border rounded-lg p-4" data-testid="drawdown-chart">
      <h3 className="text-sm font-semibold mb-2">Drawdown</h3>
      <ResponsiveContainer width="100%" height={200}>
        <AreaChart data={data}>
          <XAxis dataKey="date" tick={{ fontSize: 10 }} />
          <YAxis tick={{ fontSize: 10 }} />
          <Tooltip />
          <Area type="monotone" dataKey="drawdown_pct" stroke="#dc2626" fill="#fee2e2" />
        </AreaChart>
      </ResponsiveContainer>
    </div>
  )
}
