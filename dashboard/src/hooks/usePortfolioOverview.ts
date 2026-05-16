import { useQuery } from '@tanstack/react-query'
import { useEffect, useRef } from 'react'
import { api } from '@/lib/api'
import { joinChannel, leaveChannel } from '@/lib/ws'

export interface Holding {
  tradingsymbol: string
  exchange: string
  instrument_token: number
  quantity: number
  average_price: string
  last_price: string | null
  pnl: string | null
  day_change: string | null
  day_change_pct: string | null
  sector: string | null
}

export interface OverviewResponse {
  data: Holding[]
  meta: { freshness: 'live' | 'stale' | 'offline'; synced_at: string | null }
}

/**
 * usePortfolioOverview (T058).
 *
 * Fetches the current holdings snapshot via REST and subscribes to the
 * `portfolio:live` channel so subsequent ticks refresh last_price in
 * near-real time without re-requesting the list.
 */
export function usePortfolioOverview() {
  const query = useQuery<OverviewResponse>({
    queryKey: ['portfolio', 'holdings'],
    queryFn: async () => (await api.get('/api/v1/portfolio/holdings')).data,
    staleTime: 5_000,
  })

  const refetchRef = useRef(query.refetch)
  refetchRef.current = query.refetch

  useEffect(() => {
    const ch = joinChannel('portfolio:live')
    ch.on('tick', () => { refetchRef.current() })
    return () => {
      leaveChannel('portfolio:live')
    }
  }, [])

  return query
}
