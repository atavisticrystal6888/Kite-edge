import { useState } from 'react'
import { usePortfolioOverview, type Holding } from '@/hooks/usePortfolioOverview'
import { AllocationCharts } from '@/components/portfolio/AllocationCharts'
import { HoldingDetailDrawer } from '@/components/portfolio/HoldingDetailDrawer'

/**
 * PortfolioOverviewPage (T055).
 * US1 landing view: shows every holding with live P&L plus the allocation
 * summary. Clicking a row opens the detail drawer (US3).
 */
export function PortfolioOverviewPage() {
  const { data, isLoading, error } = usePortfolioOverview()
  const [selected, setSelected] = useState<Holding | null>(null)

  if (isLoading) return <p className="p-6">Loading holdings…</p>
  if (error) return <p className="p-6 text-red-600">Failed to load holdings.</p>
  if (!data) return null

  const freshness = data.meta.freshness
  return (
    <div className="p-6 space-y-6">
      <header className="flex items-center justify-between">
        <h1 className="text-2xl font-semibold">Portfolio</h1>
        <span
          className={
            freshness === 'live'
              ? 'text-xs px-2 py-1 rounded bg-green-50 text-green-700'
              : freshness === 'stale'
              ? 'text-xs px-2 py-1 rounded bg-amber-50 text-amber-700'
              : 'text-xs px-2 py-1 rounded bg-red-50 text-red-700'
          }
        >
          {freshness.toUpperCase()}
        </span>
      </header>

      <AllocationCharts holdings={data.data} />

      <table className="w-full text-sm">
        <thead>
          <tr className="text-left text-slate-500 border-b">
            <th className="py-2">Symbol</th>
            <th>Qty</th>
            <th>Avg</th>
            <th>LTP</th>
            <th>P&amp;L</th>
            <th>Day %</th>
          </tr>
        </thead>
        <tbody>
          {data.data.map((h) => (
            <tr
              key={`${h.exchange}:${h.tradingsymbol}`}
              className="border-b hover:bg-slate-50 cursor-pointer"
              onClick={() => setSelected(h)}
            >
              <td className="py-2 font-medium">{h.tradingsymbol}</td>
              <td>{h.quantity}</td>
              <td>{Number(h.average_price).toFixed(2)}</td>
              <td>{h.last_price ? Number(h.last_price).toFixed(2) : '—'}</td>
              <td className={Number(h.pnl ?? 0) >= 0 ? 'text-green-600' : 'text-red-600'}>
                {h.pnl ? Number(h.pnl).toFixed(2) : '—'}
              </td>
              <td>{h.day_change_pct ? `${Number(h.day_change_pct).toFixed(2)}%` : '—'}</td>
            </tr>
          ))}
        </tbody>
      </table>

      <HoldingDetailDrawer holding={selected} onClose={() => setSelected(null)} />
    </div>
  )
}
