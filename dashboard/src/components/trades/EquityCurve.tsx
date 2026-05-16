/** T150: Equity curve and drawdown chart. */
import { LineChart, Line, XAxis, YAxis, ResponsiveContainer, Tooltip } from 'recharts'

export function EquityCurve({ data }: { data: { date: string; equity: number }[] }) {
  return (
    <div className="border rounded-lg p-4" data-testid="equity-curve">
      <h3 className="text-sm font-semibold mb-2">Equity Curve</h3>
      <ResponsiveContainer width="100%" height={200}>
        <LineChart data={data}>
          <XAxis dataKey="date" tick={{ fontSize: 10 }} />
          <YAxis tick={{ fontSize: 10 }} />
          <Tooltip />
          <Line type="monotone" dataKey="equity" stroke="#2563eb" strokeWidth={2} dot={false} />
        </LineChart>
      </ResponsiveContainer>
    </div>
  )
}
