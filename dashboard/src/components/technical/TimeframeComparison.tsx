/**
 * T081: Timeframe comparison component.
 */
export function TimeframeComparison({
  data,
}: {
  data: { timeframe: string; score: number; band: string }[]
}) {
  return (
    <div className="grid grid-cols-3 gap-3" data-testid="timeframe-comparison">
      {data.map((tf) => (
        <div key={tf.timeframe} className="border rounded-lg p-3 text-center">
          <div className="text-xs text-slate-500 mb-1">{tf.timeframe.toUpperCase()}</div>
          <div className="text-xl font-bold">{tf.score.toFixed(0)}</div>
          <div
            className={`text-xs ${
              tf.band.includes('Buy') ? 'text-green-600' : tf.band.includes('Sell') ? 'text-red-600' : 'text-slate-600'
            }`}
          >
            {tf.band}
          </div>
        </div>
      ))}
    </div>
  )
}
