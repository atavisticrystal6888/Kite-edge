/** T110: Stress scenario picker and impact table. */
import { useState } from 'react'

const SCENARIOS = [
  { code: 'CRASH_2020_03', name: 'COVID Crash (Mar 2020)' },
  { code: 'GFC_2008', name: 'Global Financial Crisis (2008)' },
  { code: 'DEMONETIZATION_2016', name: 'Demonetization (Nov 2016)' },
  { code: 'TAPER_TANTRUM_2013', name: 'Taper Tantrum (2013)' },
]

export function StressScenarioPanel({
  onRun,
  result,
}: {
  onRun: (code: string) => void
  result: { portfolio_impact_pct: number; holding_impacts: { symbol: string; impact_pct: number }[] } | null
}) {
  const [selected, setSelected] = useState(SCENARIOS[0].code)

  return (
    <div className="border rounded-lg p-4" data-testid="stress-panel">
      <h3 className="text-sm font-semibold mb-2">Stress Test</h3>
      <div className="flex gap-2 mb-3">
        <select
          value={selected}
          onChange={(e) => setSelected(e.target.value)}
          className="text-sm border rounded px-2 py-1"
        >
          {SCENARIOS.map((s) => (
            <option key={s.code} value={s.code}>
              {s.name}
            </option>
          ))}
        </select>
        <button onClick={() => onRun(selected)} className="text-sm bg-blue-600 text-white px-3 py-1 rounded">
          Run
        </button>
      </div>
      {result && (
        <div>
          <p className="text-sm mb-2">
            Portfolio impact: <strong className="text-red-600">{result.portfolio_impact_pct.toFixed(2)}%</strong>
          </p>
          <table className="w-full text-xs">
            <thead>
              <tr className="border-b text-left text-slate-500">
                <th className="py-1">Symbol</th>
                <th>Impact %</th>
              </tr>
            </thead>
            <tbody>
              {result.holding_impacts.map((h) => (
                <tr key={h.symbol} className="border-b">
                  <td className="py-1">{h.symbol}</td>
                  <td className="text-red-600">{h.impact_pct.toFixed(2)}%</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  )
}
