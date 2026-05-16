/**
 * T077: Indicator overlay layer for candlestick chart.
 */
export function IndicatorOverlays({
  indicators,
}: {
  indicators: { name: string; value: number | null; signal: string | null }[]
}) {
  if (!indicators.length) return <p className="text-sm text-slate-400">No indicators computed.</p>

  return (
    <div className="flex flex-wrap gap-2 text-xs" data-testid="indicator-overlays">
      {indicators.map((ind) => (
        <span
          key={ind.name}
          className={`px-2 py-1 rounded border ${
            ind.signal === 'buy' || ind.signal === 'oversold'
              ? 'border-green-300 bg-green-50 text-green-700'
              : ind.signal === 'sell' || ind.signal === 'overbought'
              ? 'border-red-300 bg-red-50 text-red-700'
              : 'border-slate-200 bg-slate-50 text-slate-600'
          }`}
        >
          {ind.name}: {ind.value !== null ? ind.value.toFixed(2) : '—'} {ind.signal && `(${ind.signal})`}
        </span>
      ))}
    </div>
  )
}
