/** T105: Risk metric cards. */
export function RiskCards({ ratios }: { ratios: Record<string, number> }) {
  const cards = [
    { label: 'Sharpe', key: 'sharpe' },
    { label: 'Sortino', key: 'sortino' },
    { label: 'Calmar', key: 'calmar' },
    { label: 'Beta', key: 'beta' },
    { label: 'Alpha', key: 'alpha' },
  ]
  return (
    <div className="grid grid-cols-2 md:grid-cols-5 gap-3" data-testid="risk-cards">
      {cards.map((c) => (
        <div key={c.key} className="border rounded-lg p-3 text-center">
          <div className="text-xs text-slate-500">{c.label}</div>
          <div className="text-lg font-semibold">{ratios[c.key]?.toFixed(3) ?? '—'}</div>
        </div>
      ))}
    </div>
  )
}
