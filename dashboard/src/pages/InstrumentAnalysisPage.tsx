/**
 * T083: Instrument Analysis Page — assembles chart, overlays, summary, config.
 */
import { useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import { useTechnicalAnalysis } from '@/hooks/useTechnicalAnalysis'
import { InstrumentSearch } from '@/components/technical/InstrumentSearch'
import { CandlestickChart } from '@/components/charts/CandlestickChart'
import { IndicatorOverlays } from '@/components/charts/IndicatorOverlays'
import { SummaryGauge } from '@/components/technical/SummaryGauge'
import { SummaryBreakdown } from '@/components/technical/SummaryBreakdown'
import { IndicatorConfigPanel } from '@/components/technical/IndicatorConfigPanel'
import { TimeframeComparison } from '@/components/technical/TimeframeComparison'
import { api } from '@/lib/api'

function useOHLCV(symbol: string, exchange = 'NSE') {
  return useQuery({
    queryKey: ['ohlcv', symbol, exchange],
    queryFn: async () => (await api.get(`/api/v1/instruments/${symbol}/ohlcv`, { params: { exchange } })).data,
    enabled: !!symbol,
  })
}

export function InstrumentAnalysisPage() {
  const [symbol, setSymbol] = useState('')
  const { data, isLoading } = useTechnicalAnalysis(symbol)
  const { data: ohlcv } = useOHLCV(symbol)

  const candles = (ohlcv?.candles ?? []).map((c: { date: string; open: number; high: number; low: number; close: number }) => ({
    time: c.date,
    open: c.open,
    high: c.high,
    low: c.low,
    close: c.close,
  }))

  return (
    <div className="p-6 space-y-6">
      <header>
        <h1 className="text-2xl font-semibold mb-4">Instrument Analysis</h1>
        <InstrumentSearch onSelect={setSymbol} />
      </header>

      {isLoading && <p>Loading analysis…</p>}

      {data && (
        <>
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
            <div className="lg:col-span-2">
              <CandlestickChart data={candles} />
              <div className="mt-3">
                <IndicatorOverlays indicators={data.indicator_groups.trend ?? []} />
              </div>
            </div>
            <div className="space-y-4">
              <SummaryGauge score={data.summary_score.score} band={data.summary_score.band} />
              <SummaryBreakdown contributors={(data.summary_score.contributors ?? []).map((c: {indicator: string; weight: number; group?: string}) => ({ ...c, group: c.group ?? 'other' }))} />
              <TimeframeComparison
                data={data.timeframes.map((tf) => ({ timeframe: tf, score: data.summary_score.score, band: data.summary_score.band }))}
              />
            </div>
          </div>
          <IndicatorConfigPanel />
        </>
      )}
    </div>
  )
}
