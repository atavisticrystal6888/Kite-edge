/** T107: Correlation heatmap. */
export function CorrelationHeatmap({
  symbols,
  matrix,
}: {
  symbols: string[]
  matrix: number[][]
}) {
  const colorScale = (v: number) => {
    if (v >= 0.7) return 'bg-red-200'
    if (v >= 0.4) return 'bg-orange-100'
    if (v >= -0.4) return 'bg-slate-50'
    if (v >= -0.7) return 'bg-blue-100'
    return 'bg-blue-200'
  }

  return (
    <div className="border rounded-lg p-4 overflow-auto" data-testid="correlation-heatmap">
      <h3 className="text-sm font-semibold mb-2">Correlation Matrix</h3>
      <table className="text-xs">
        <thead>
          <tr>
            <th />
            {symbols.map((s) => (
              <th key={s} className="px-2 py-1">
                {s}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {symbols.map((s, i) => (
            <tr key={s}>
              <td className="font-medium pr-2">{s}</td>
              {matrix[i]?.map((v, j) => (
                <td key={j} className={`px-2 py-1 text-center ${colorScale(v)}`}>
                  {v?.toFixed(2) ?? '—'}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}
