/** T133: Predictions page + query hook. */
import { useQuery } from '@tanstack/react-query'
import { api } from '@/lib/api'
import { ForecastChart } from '@/components/forecast/ForecastChart'
import { SignalFeed } from '@/components/forecast/SignalFeed'
import { PredictionDisclaimer } from '@/components/forecast/Disclaimer'

function useForecast(symbol: string) {
  return useQuery({
    queryKey: ['forecast', symbol],
    queryFn: async () => (await api.post(`/api/v1/analytics/forecast/${symbol}`, {})).data,
    enabled: !!symbol,
  })
}

export function PredictionsPage() {
  const { data, isLoading } = useForecast('NIFTY50')

  return (
    <div className="p-6 space-y-6">
      <h1 className="text-2xl font-semibold">Predictions</h1>
      <PredictionDisclaimer />
      {isLoading && <p>Loading forecasts…</p>}
      {data && (
        <>
          <ForecastChart data={data.forecasts ?? []} />
          <SignalFeed signals={data.signals ?? []} />
        </>
      )}
    </div>
  )
}
