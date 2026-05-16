/** T166: Actionable signal cards. */
export function SignalCards({
  signals,
}: {
  signals: { symbol: string; name: string; direction: string; confidence_score: number; rationale: string; rank: number }[]
}) {
  return (
    <div className="grid grid-cols-1 md:grid-cols-2 gap-3" data-testid="signal-cards">
      {signals.map((s, i) => (
        <div key={i} className="border rounded-lg p-4">
          <div className="flex justify-between items-start">
            <div>
              <span className="font-medium">{s.symbol}</span>
              <span className={`ml-2 text-xs px-1.5 py-0.5 rounded ${s.direction === 'bullish' ? 'bg-green-50 text-green-700' : 'bg-red-50 text-red-700'}`}>
                {s.direction}
              </span>
            </div>
            <span className="text-xs text-slate-400">#{s.rank}</span>
          </div>
          <p className="text-sm text-slate-600 mt-1">{s.name}</p>
          <p className="text-xs text-slate-400 mt-1">{s.rationale}</p>
          <div className="text-xs text-slate-500 mt-2">Confidence: {(s.confidence_score * 100).toFixed(0)}%</div>
        </div>
      ))}
    </div>
  )
}
