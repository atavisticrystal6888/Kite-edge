/**
 * T078: Technical summary gauge.
 */
export function SummaryGauge({ score, band }: { score: number; band: string }) {
  const color =
    band === 'Strong Buy'
      ? 'text-green-700 bg-green-50'
      : band === 'Buy'
      ? 'text-green-600 bg-green-50'
      : band === 'Sell'
      ? 'text-red-600 bg-red-50'
      : band === 'Strong Sell'
      ? 'text-red-700 bg-red-50'
      : 'text-slate-600 bg-slate-50'

  return (
    <div className={`inline-flex items-center gap-2 px-4 py-2 rounded-lg ${color}`} data-testid="summary-gauge">
      <span className="text-2xl font-bold">{score.toFixed(0)}</span>
      <span className="text-sm font-medium">{band}</span>
    </div>
  )
}
