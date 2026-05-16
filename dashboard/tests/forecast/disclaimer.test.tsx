/**
 * T117: UI tests for prediction disclaimer rendering.
 */
import { describe, it, expect } from 'vitest'
import { render, screen } from '@testing-library/react'
import { PredictionDisclaimer } from '@/components/forecast/Disclaimer'

describe('PredictionDisclaimer', () => {
  it('renders the prediction disclaimer', () => {
    render(<PredictionDisclaimer />)
    const node = screen.getByTestId('disclaimer-prediction')
    expect(node).toBeInTheDocument()
    expect(node.textContent).toMatch(/statistical projections/i)
  })
})
