/** T169a: Watchlist management UI. */
import { useWatchlists, useCreateWatchlist, useDeleteWatchlist } from '@/hooks/useWatchlists'
import { useState } from 'react'

export function WatchlistManager() {
  const { data: watchlists } = useWatchlists()
  const create = useCreateWatchlist()
  const del = useDeleteWatchlist()
  const [name, setName] = useState('')

  return (
    <div className="border rounded-lg p-4" data-testid="watchlist-manager">
      <h3 className="text-sm font-semibold mb-2">Watchlists</h3>
      <div className="flex gap-2 mb-3">
        <input type="text" placeholder="New watchlist…" value={name} onChange={(e) => setName(e.target.value)} className="border rounded px-2 py-1 text-sm flex-1" />
        <button onClick={() => { create.mutate({ name, symbols: [] }); setName('') }} className="bg-blue-600 text-white text-sm px-3 py-1 rounded">Create</button>
      </div>
      <ul className="space-y-1">
        {(watchlists ?? []).map((wl: { id: number; name: string }) => (
          <li key={wl.id} className="flex justify-between items-center text-sm">
            <span>{wl.name}</span>
            <button onClick={() => del.mutate(wl.id)} className="text-xs text-red-500 hover:underline">Delete</button>
          </li>
        ))}
      </ul>
    </div>
  )
}
