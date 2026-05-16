/** T168: Diversification radar and insights. */
export function DiversificationRadar({
  data,
}: {
  data: { diversification_score: number; hhi: number; suggestions: string[]; sector_weights: Record<string, number> }
}) {
  return (
    <div className="border rounded-lg p-4" data-testid="diversification-radar">
      <h3 className="text-sm font-semibold mb-2">Diversification</h3>
      <div className="flex items-center gap-4 mb-3">
        <div className="text-3xl font-bold">{data.diversification_score}</div>
        <div className="text-xs text-slate-500">
          HHI: {data.hhi.toFixed(4)}
        </div>
      </div>
      {data.suggestions.length > 0 && (
        <ul className="text-xs text-slate-600 space-y-1">
          {data.suggestions.map((s, i) => (
            <li key={i}>• {s}</li>
          ))}
        </ul>
      )}
    </div>
  )
}
