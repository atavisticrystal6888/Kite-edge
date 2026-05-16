/**
 * T079: Summary contributor breakdown panel.
 */
export function SummaryBreakdown({
  contributors,
}: {
  contributors: { indicator: string; group: string; weight: number }[]
}) {
  if (!contributors.length) return <p className="text-sm text-slate-400">No contributors.</p>

  return (
    <div data-testid="summary-breakdown" className="space-y-1">
      <h4 className="text-sm font-semibold mb-1">Contributors</h4>
      {contributors.map((c) => (
        <div key={c.indicator} className="flex justify-between text-xs">
          <span>
            {c.indicator} <span className="text-slate-400">({c.group})</span>
          </span>
          <span className={c.weight > 0 ? 'text-green-600' : c.weight < 0 ? 'text-red-600' : ''}>
            {c.weight > 0 ? '+' : ''}
            {c.weight}
          </span>
        </div>
      ))}
    </div>
  )
}
