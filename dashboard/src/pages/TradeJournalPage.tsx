/** T151: Trade Journal page. */
import { useQuery } from '@tanstack/react-query'
import { api } from '@/lib/api'
import { TradeHistory } from '@/components/trades/TradeHistory'

function useTradePerformance() {
  return useQuery({
    queryKey: ['trades', 'performance'],
    queryFn: async () => (await api.get('/api/v1/analytics/trades/performance')).data,
  })
}

export function TradeJournalPage() {
  const { data, isLoading } = useTradePerformance()

  return (
    <div className="p-6 space-y-6">
      <h1 className="text-2xl font-semibold">Trade Journal</h1>
      {isLoading && <p>Loading trades…</p>}
      {data && <TradeHistory trades={[]} />}
    </div>
  )
}
