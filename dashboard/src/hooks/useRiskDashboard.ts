import { useQuery } from '@tanstack/react-query'
import { api } from '@/lib/api'

export function useRiskDashboard() {
  return useQuery({
    queryKey: ['risk', 'portfolio'],
    queryFn: async () => (await api.post('/api/v1/analytics/risk/portfolio', {})).data,
  })
}

export function useVaR() {
  return useQuery({
    queryKey: ['risk', 'var'],
    queryFn: async () => (await api.post('/api/v1/analytics/risk/var', {})).data,
  })
}

export function useMonteCarlo() {
  return useQuery({
    queryKey: ['risk', 'montecarlo'],
    queryFn: async () => (await api.post('/api/v1/analytics/risk/montecarlo', {})).data,
  })
}
