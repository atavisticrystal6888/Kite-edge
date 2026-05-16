/**
 * T137: UI integration tests for the trade dashboard flow.
 */
import { describe, it, expect } from 'vitest'
import { render, screen } from '@testing-library/react'
import { PerformanceDashboard } from '@/components/trades/PerformanceDashboard'

describe('PerformanceDashboard', () => {
  it('renders trade metrics', () => {
    const metrics = { total_trades: 42, win_rate: 55.5, expectancy: 120.5, total_pnl: 5000, profit_factor: 1.8 }
    render(<PerformanceDashboard metrics={metrics} />)
    expect(screen.getByTestId('trade-performance')).toBeInTheDocument()
    expect(screen.getByText('42')).toBeInTheDocument()
  })
})
