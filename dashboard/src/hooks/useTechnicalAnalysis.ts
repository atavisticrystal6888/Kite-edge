import { useQuery } from '@tanstack/react-query'
import { api } from '@/lib/api'

export interface TechnicalData {
  instrument: { symbol: string; exchange: string }
  timeframes: string[]
  indicator_groups: Record<string, { name: string; value: number | null; signal: string | null }[]>
  patterns: { name: string; direction: string; date: string }[]
  support_resistance: { support: { price: number }[]; resistance: { price: number }[] }
  summary_score: { score: number; band: string; contributors: { indicator: string; weight: number }[] }
}

export function useTechnicalAnalysis(symbol: string, exchange = 'NSE') {
  return useQuery<TechnicalData>({
    queryKey: ['technical', symbol, exchange],
    queryFn: async () =>
      (await api.post(`/api/v1/analytics/technical/${symbol}`, { exchange, timeframes: ['1d', '1w', '1mo'] })).data,
    enabled: !!symbol,
  })
}

export function useTechnicalSummary(symbol: string, timeframe = '1d') {
  return useQuery({
    queryKey: ['technical-summary', symbol, timeframe],
    queryFn: async () =>
      (await api.get(`/api/v1/analytics/technical/${symbol}/summary`, { params: { timeframe } })).data,
    enabled: !!symbol,
  })
}
