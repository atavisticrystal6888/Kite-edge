/** T109: Monte Carlo fan chart. */
import { LineChart, Line, XAxis, YAxis, ResponsiveContainer, Tooltip } from 'recharts'

export function MonteCarloFan({
  percentiles,
}: {
  percentiles: Record<string, number>
}) {
  const data = Object.entries(percentiles).map(([p, v]) => ({ percentile: `P${p}`, value: v }))

  return (
    <div className="border rounded-lg p-4" data-testid="mc-fan-chart">
      <h3 className="text-sm font-semibold mb-2">Monte Carlo Terminal Distribution</h3>
      <ResponsiveContainer width="100%" height={200}>
        <LineChart data={data}>
          <XAxis dataKey="percentile" />
          <YAxis />
          <Tooltip />
          <Line type="monotone" dataKey="value" stroke="#2563eb" />
        </LineChart>
      </ResponsiveContainer>
    </div>
  )
}
