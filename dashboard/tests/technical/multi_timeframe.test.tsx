/**
 * T064: UI integration tests for the multi-timeframe comparison flow.
 */
import { describe, it, expect } from 'vitest'
import { render, screen } from '@testing-library/react'
import { TimeframeComparison } from '@/components/technical/TimeframeComparison'

describe('TimeframeComparison', () => {
  it('renders all timeframes', () => {
    const data = [
      { timeframe: '1d', score: 25, band: 'Buy' },
      { timeframe: '1w', score: -10, band: 'Neutral' },
      { timeframe: '1mo', score: -40, band: 'Sell' },
    ]
    render(<TimeframeComparison data={data} />)
    expect(screen.getByTestId('timeframe-comparison')).toBeInTheDocument()
    expect(screen.getByText('1D')).toBeInTheDocument()
    expect(screen.getByText('1W')).toBeInTheDocument()
    expect(screen.getByText('Buy')).toBeInTheDocument()
  })
})
