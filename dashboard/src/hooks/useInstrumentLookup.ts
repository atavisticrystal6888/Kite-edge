import { useQuery } from '@tanstack/react-query'
import { api } from '@/lib/api'

export function useInstrumentSearch(query: string) {
  return useQuery({
    queryKey: ['instruments', 'search', query],
    queryFn: async () => (await api.get('/api/v1/instruments/search', { params: { query } })).data.results,
    enabled: query.length >= 2,
  })
}

export function useInstrumentQuote(symbol: string) {
  return useQuery({
    queryKey: ['instruments', 'quote', symbol],
    queryFn: async () => (await api.get(`/api/v1/instruments/${symbol}/quote`)).data.data,
    enabled: !!symbol,
  })
}
