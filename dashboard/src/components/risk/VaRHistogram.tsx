/** T106: VaR histogram and tail view. */
import { BarChart, Bar, XAxis, YAxis, ResponsiveContainer, Tooltip } from 'recharts'

export function VaRHistogram({ data }: { data: { bin: string; count: number }[] }) {
  return (
    <div className="border rounded-lg p-4" data-testid="var-histogram">
      <h3 className="text-sm font-semibold mb-2">Value at Risk Distribution</h3>
      <ResponsiveContainer width="100%" height={200}>
        <BarChart data={data}>
          <XAxis dataKey="bin" tick={{ fontSize: 10 }} />
          <YAxis tick={{ fontSize: 10 }} />
          <Tooltip />
          <Bar dataKey="count" fill="#2563eb" />
        </BarChart>
      </ResponsiveContainer>
    </div>
  )
}
