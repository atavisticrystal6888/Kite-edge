/** T128: Forecast chart with confidence bands. */
import { LineChart, Line, Area, XAxis, YAxis, ResponsiveContainer, Tooltip } from 'recharts'

export function ForecastChart({
  data,
}: {
  data: { date: string; predicted: number; lower: number; upper: number }[]
}) {
  return (
    <div className="border rounded-lg p-4" data-testid="forecast-chart">
      <h3 className="text-sm font-semibold mb-2">Forecast</h3>
      <ResponsiveContainer width="100%" height={300}>
        <LineChart data={data}>
          <XAxis dataKey="date" tick={{ fontSize: 10 }} />
          <YAxis tick={{ fontSize: 10 }} />
          <Tooltip />
          <Area type="monotone" dataKey="upper" stroke="none" fill="#dbeafe" />
          <Area type="monotone" dataKey="lower" stroke="none" fill="#dbeafe" />
          <Line type="monotone" dataKey="predicted" stroke="#2563eb" strokeWidth={2} dot={false} />
        </LineChart>
      </ResponsiveContainer>
    </div>
  )
}
