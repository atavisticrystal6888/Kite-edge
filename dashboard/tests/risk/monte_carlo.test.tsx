/**
 * T090: UI integration tests for Monte Carlo fan chart flow.
 */
import { describe, it, expect } from 'vitest'
import { render, screen } from '@testing-library/react'
import { MonteCarloFan } from '@/components/risk/MonteCarloFan'

describe('MonteCarloFan', () => {
  it('renders fan chart with percentiles', () => {
    const percentiles = { '5': 85000, '25': 95000, '50': 105000, '75': 115000, '95': 130000 }
    render(<MonteCarloFan percentiles={percentiles} />)
    expect(screen.getByTestId('mc-fan-chart')).toBeInTheDocument()
  })
})
