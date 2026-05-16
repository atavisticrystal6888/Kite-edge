/**
 * T083a: Instrument search combobox.
 */
import { useState } from 'react'
import { useInstrumentSearch } from '@/hooks/useInstrumentLookup'

export function InstrumentSearch({ onSelect }: { onSelect: (symbol: string) => void }) {
  const [query, setQuery] = useState('')
  const { data: results } = useInstrumentSearch(query)

  return (
    <div className="relative" data-testid="instrument-search">
      <input
        type="text"
        placeholder="Search instruments…"
        value={query}
        onChange={(e) => setQuery(e.target.value)}
        className="w-full border rounded px-3 py-2 text-sm"
      />
      {results && results.length > 0 && (
        <ul className="absolute z-10 w-full bg-white border rounded mt-1 max-h-48 overflow-y-auto shadow-lg">
          {results.map((r: { symbol: string; exchange: string; name: string }) => (
            <li
              key={`${r.exchange}:${r.symbol}`}
              className="px-3 py-2 text-sm hover:bg-slate-50 cursor-pointer"
              onClick={() => {
                onSelect(r.symbol)
                setQuery(r.symbol)
              }}
            >
              <span className="font-medium">{r.symbol}</span>
              <span className="text-slate-400 ml-2">{r.exchange}</span>
              {r.name && <span className="text-slate-400 ml-2">— {r.name}</span>}
            </li>
          ))}
        </ul>
      )}
    </div>
  )
}
