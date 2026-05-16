import { useEffect, useRef } from 'react'
import { createChart, type IChartApi, type CandlestickData } from 'lightweight-charts'

/**
 * T076: Candlestick chart component using lightweight-charts.
 */
export function CandlestickChart({ data }: { data: CandlestickData[] }) {
  const ref = useRef<HTMLDivElement>(null)
  const chartRef = useRef<IChartApi | null>(null)

  useEffect(() => {
    if (!ref.current) return
    const chart = createChart(ref.current, {
      width: ref.current.clientWidth,
      height: 400,
      layout: { background: { color: '#ffffff' }, textColor: '#333' },
      grid: { vertLines: { color: '#f0f0f0' }, horzLines: { color: '#f0f0f0' } },
    })
    const series = chart.addCandlestickSeries()
    series.setData(data)
    chart.timeScale().fitContent()
    chartRef.current = chart

    const ro = new ResizeObserver(() => {
      if (ref.current) chart.resize(ref.current.clientWidth, 400)
    })
    ro.observe(ref.current)

    return () => {
      ro.disconnect()
      chart.remove()
    }
  }, [data])

  return <div ref={ref} className="w-full" data-testid="candlestick-chart" />
}
