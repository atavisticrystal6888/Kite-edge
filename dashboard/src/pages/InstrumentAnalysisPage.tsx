/**
 * T083: Instrument Analysis Page — assembles chart, overlays, summary, config.
 */
import { useState } from 'react'
import { useTechnicalAnalysis } from '@/hooks/useTechnicalAnalysis'
import { InstrumentSearch } from '@/components/technical/InstrumentSearch'
import { CandlestickChart } from '@/components/charts/CandlestickChart'
import { IndicatorOverlays } from '@/components/charts/IndicatorOverlays'
import { SummaryGauge } from '@/components/technical/SummaryGauge'
import { SummaryBreakdown } from '@/components/technical/SummaryBreakdown'
import { IndicatorConfigPanel } from '@/components/technical/IndicatorConfigPanel'
import { TimeframeComparison } from '@/components/technical/TimeframeComparison'

export function InstrumentAnalysisPage() {
  const [symbol, setSymbol] = useState('')
  const { data, isLoading } = useTechnicalAnalysis(symbol)

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
              <CandlestickChart data={[]} />
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
