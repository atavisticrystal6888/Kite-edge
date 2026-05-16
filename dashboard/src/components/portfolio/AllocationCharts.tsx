import type { Holding } from '@/hooks/usePortfolioOverview'
import { PieChart, Pie, Cell, ResponsiveContainer, Tooltip, Legend } from 'recharts'

const COLORS = ['#2563eb', '#16a34a', '#eab308', '#dc2626', '#9333ea', '#0ea5e9', '#f97316']

function byBucket(rows: Holding[], keyFn: (h: Holding) => string) {
  const totals = new Map<string, number>()
  for (const h of rows) {
    const price = Number(h.last_price ?? h.average_price)
    const value = h.quantity * price
    const k = keyFn(h)
    totals.set(k, (totals.get(k) ?? 0) + value)
  }
  return [...totals.entries()]
    .map(([name, value]) => ({ name, value }))
    .sort((a, b) => b.value - a.value)
}

export function AllocationCharts({ holdings }: { holdings: Holding[] }) {
  const sectorData = byBucket(holdings, (h) => h.sector ?? 'Unclassified')

  return (
    <section className="grid grid-cols-1 md:grid-cols-2 gap-6">
      <div className="rounded-lg border border-slate-200 p-4" data-testid="sector-allocation">
        <h3 className="text-sm font-semibold mb-2">Sector allocation</h3>
        <ResponsiveContainer width="100%" height={240}>
          <PieChart>
            <Pie data={sectorData} dataKey="value" nameKey="name" outerRadius={90} label>
              {sectorData.map((_, i) => (
                <Cell key={i} fill={COLORS[i % COLORS.length]} />
              ))}
            </Pie>
            <Tooltip />
            <Legend />
          </PieChart>
        </ResponsiveContainer>
      </div>
    </section>
  )
}
