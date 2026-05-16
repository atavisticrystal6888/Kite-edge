/**
 * T055c: Login footer disclaimer must render the canonical risk language.
 */
import { describe, it, expect } from 'vitest'
import { render, screen } from '@testing-library/react'
import { LoginFooterDisclaimer } from '@/components/auth/LoginFooterDisclaimer'

describe('LoginFooterDisclaimer', () => {
  it('renders the login disclaimer variant', () => {
    render(<LoginFooterDisclaimer />)
    const node = screen.getByTestId('disclaimer-login')
    expect(node).toBeInTheDocument()
    expect(node.textContent).toMatch(/does not provide investment advice/i)
    expect(node.textContent).toMatch(/does not execute trades/i)
    expect(node.textContent).toMatch(/risk/i)
  })
})
