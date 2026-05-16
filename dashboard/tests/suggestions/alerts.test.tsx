/**
 * T155: UI flow tests for suggestions and alerts.
 */
import { describe, it, expect } from 'vitest'
import { render, screen } from '@testing-library/react'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { AlertConfig } from '@/components/suggestions/AlertConfig'

const wrapper = ({ children }: { children: React.ReactNode }) => (
  <QueryClientProvider client={new QueryClient({ defaultOptions: { queries: { retry: false } } })}>
    {children}
  </QueryClientProvider>
)

describe('AlertConfig', () => {
  it('renders alert configuration form', () => {
    render(<AlertConfig />, { wrapper })
    expect(screen.getByTestId('alert-config')).toBeInTheDocument()
  })
})
