import type { Holding } from '@/hooks/usePortfolioOverview'

/**
 * HoldingDetailDrawer (T057).
 * Minimal slide-in drawer showing a single holding's cost basis, market
 * value, absolute P&L, and daily change. Deeper technical/risk views live
 * in the instrument analysis page (Phase 4).
 */
export function HoldingDetailDrawer({
  holding,
  onClose,
}: {
  holding: Holding | null
  onClose: () => void
}) {
  if (!holding) return null

  const avg = Number(holding.average_price)
  const last = Number(holding.last_price ?? holding.average_price)
  const marketValue = holding.quantity * last
  const invested = holding.quantity * avg
  const pnl = marketValue - invested
  const pnlPct = invested === 0 ? 0 : (pnl / invested) * 100

  return (
    <aside
      className="fixed inset-y-0 right-0 w-[380px] bg-white border-l shadow-xl p-6 overflow-y-auto"
      role="dialog"
      aria-label={`${holding.tradingsymbol} details`}
    >
      <header className="flex items-start justify-between mb-4">
        <div>
          <h2 className="text-lg font-semibold">{holding.tradingsymbol}</h2>
          <p className="text-xs text-slate-500">
            {holding.exchange} · {holding.sector ?? 'Unclassified'}
          </p>
        </div>
        <button onClick={onClose} aria-label="Close" className="text-slate-400 hover:text-slate-700">
          ×
        </button>
      </header>
      <dl className="space-y-2 text-sm">
        <Row label="Quantity" value={holding.quantity.toString()} />
        <Row label="Avg. price" value={avg.toFixed(2)} />
        <Row label="Last price" value={last.toFixed(2)} />
        <Row label="Market value" value={marketValue.toFixed(2)} />
        <Row label="Invested" value={invested.toFixed(2)} />
        <Row label="P&L" value={`${pnl.toFixed(2)} (${pnlPct.toFixed(2)}%)`} tone={pnl >= 0 ? 'pos' : 'neg'} />
      </dl>
    </aside>
  )
}

function Row({ label, value, tone }: { label: string; value: string; tone?: 'pos' | 'neg' }) {
  const toneCls = tone === 'pos' ? 'text-green-600' : tone === 'neg' ? 'text-red-600' : ''
  return (
    <div className="flex justify-between">
      <dt className="text-slate-500">{label}</dt>
      <dd className={`font-medium ${toneCls}`}>{value}</dd>
    </div>
  )
}
