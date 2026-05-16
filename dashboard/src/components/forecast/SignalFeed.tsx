/** T129: Predictive signal feed. */
export function SignalFeed({
  signals,
}: {
  signals: { name: string; direction: string; symbol: string; confidence_score: number; rationale: string }[]
}) {
  return (
    <div className="space-y-2" data-testid="signal-feed">
      {signals.length === 0 && <p className="text-sm text-slate-400">No active signals.</p>}
      {signals.map((s, i) => (
        <div key={i} className="border rounded-lg p-3 flex justify-between items-start">
          <div>
            <span className="font-medium text-sm">{s.symbol}</span>
            <span className={`ml-2 text-xs px-1.5 py-0.5 rounded ${s.direction === 'bullish' ? 'bg-green-50 text-green-700' : s.direction === 'bearish' ? 'bg-red-50 text-red-700' : 'bg-slate-50'}`}>
              {s.direction}
            </span>
            <p className="text-xs text-slate-500 mt-1">{s.rationale}</p>
          </div>
          <span className="text-xs text-slate-400">{(s.confidence_score * 100).toFixed(0)}%</span>
        </div>
      ))}
    </div>
  )
}
