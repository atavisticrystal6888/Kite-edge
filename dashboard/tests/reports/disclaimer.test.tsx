/**
 * T184b: UI tests for report disclaimer on tear sheets and exports.
 */
import { describe, it, expect } from 'vitest'
import { render, screen } from '@testing-library/react'
import { ReportDisclaimer } from '@/components/reports/ReportDisclaimer'

describe('ReportDisclaimer', () => {
  it('renders the report disclaimer variant', () => {
    render(<ReportDisclaimer />)
    const node = screen.getByTestId('disclaimer-report')
    expect(node).toBeInTheDocument()
    expect(node.textContent).toMatch(/reconciliation differences/i)
  })
})
