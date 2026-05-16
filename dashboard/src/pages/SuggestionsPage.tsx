/** T170: Suggestions page + query hook. */
import { useQuery } from '@tanstack/react-query'
import { api } from '@/lib/api'
import { SignalCards } from '@/components/suggestions/SignalCards'
import { AlertConfig } from '@/components/suggestions/AlertConfig'
import { WatchlistManager } from '@/components/suggestions/WatchlistManager'
import { SuggestionDisclaimer } from '@/components/suggestions/Disclaimer'

function useSignals() {
  return useQuery({
    queryKey: ['signals'],
    queryFn: async () => (await api.get('/api/v1/analytics/signals')).data,
  })
}

export function SuggestionsPage() {
  const { data, isLoading } = useSignals()

  return (
    <div className="p-6 space-y-6">
      <h1 className="text-2xl font-semibold">Suggestions & Alerts</h1>
      <SuggestionDisclaimer />
      {isLoading && <p>Loading signals…</p>}
      {data && <SignalCards signals={data.signals ?? []} />}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <AlertConfig />
        <WatchlistManager />
      </div>
    </div>
  )
}
