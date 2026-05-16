/**
 * T170b: UI tests for suggestion disclaimer.
 */
import { describe, it, expect } from 'vitest'
import { render, screen } from '@testing-library/react'
import { SuggestionDisclaimer } from '@/components/suggestions/Disclaimer'

describe('SuggestionDisclaimer', () => {
  it('renders the suggestion disclaimer variant', () => {
    render(<SuggestionDisclaimer />)
    const node = screen.getByTestId('disclaimer-suggestion')
    expect(node).toBeInTheDocument()
    expect(node.textContent).toMatch(/heuristic screens/i)
  })
})
