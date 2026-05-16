import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { BrowserRouter, Route, Routes, Link, Navigate } from 'react-router-dom'
import { Component, type ReactNode } from 'react'
import { PortfolioOverviewPage } from '@/pages/PortfolioOverviewPage'
import { InstrumentAnalysisPage } from '@/pages/InstrumentAnalysisPage'
import { RiskDashboardPage } from '@/pages/RiskDashboardPage'
import { PredictionsPage } from '@/pages/PredictionsPage'
import { TradeJournalPage } from '@/pages/TradeJournalPage'
import { SuggestionsPage } from '@/pages/SuggestionsPage'
import { ReportsPage } from '@/pages/ReportsPage'
import { SettingsPage } from '@/pages/SettingsPage'
import { LoginFooterDisclaimer } from '@/components/auth/LoginFooterDisclaimer'
import { RequireAuth } from '@/components/auth/RequireAuth'

class ErrorBoundary extends Component<{ children: ReactNode }, { hasError: boolean; error: Error | null }> {
  state = { hasError: false, error: null as Error | null }

  static getDerivedStateFromError(error: Error) {
    return { hasError: true, error }
  }

  render() {
    if (this.state.hasError) {
      return (
        <div className="min-h-screen flex flex-col items-center justify-center p-8">
          <h1 className="text-xl font-semibold text-red-600 mb-2">Something went wrong</h1>
          <p className="text-sm text-slate-600 mb-4">{this.state.error?.message}</p>
          <button onClick={() => window.location.reload()} className="px-4 py-2 bg-blue-600 text-white rounded text-sm">
            Reload
          </button>
        </div>
      )
    }
    return this.props.children
  }
}

const queryClient = new QueryClient()

const NAV = [
  { to: '/dashboard', label: 'Portfolio' },
  { to: '/analysis', label: 'Analysis' },
  { to: '/risk', label: 'Risk' },
  { to: '/predictions', label: 'Predictions' },
  { to: '/trades', label: 'Trades' },
  { to: '/suggestions', label: 'Signals' },
  { to: '/reports', label: 'Reports' },
  { to: '/settings', label: 'Settings' },
]

function Nav() {
  return (
    <nav className="border-b bg-white px-6 py-2 flex items-center gap-6">
      <Link to="/" className="font-bold text-lg text-blue-600">KiteEdge</Link>
      {NAV.map((n) => (
        <Link key={n.to} to={n.to} className="text-sm text-slate-600 hover:text-blue-600">
          {n.label}
        </Link>
      ))}
    </nav>
  )
}

function LoginPage() {
  const apiKey = import.meta.env.VITE_KITE_API_KEY ?? ''
  return (
    <main className="min-h-screen flex flex-col items-center justify-center p-8">
      <h1 className="text-3xl font-semibold mb-4">KiteEdge</h1>
      <a
        href={`${import.meta.env.VITE_GATEWAY_URL ?? 'http://localhost:4000'}/auth/kite/login`}
        className="px-4 py-2 rounded bg-blue-600 text-white"
      >
        Sign in with Kite {apiKey && `(${apiKey.slice(0, 4)}…)`}
      </a>
      <LoginFooterDisclaimer />
    </main>
  )
}

export default function App() {
  return (
    <ErrorBoundary>
      <QueryClientProvider client={queryClient}>
        <BrowserRouter>
          <Nav />
          <Routes>
            <Route path="/" element={<LoginPage />} />
            <Route path="/dashboard" element={<RequireAuth><PortfolioOverviewPage /></RequireAuth>} />
            <Route path="/analysis" element={<RequireAuth><InstrumentAnalysisPage /></RequireAuth>} />
            <Route path="/risk" element={<RequireAuth><RiskDashboardPage /></RequireAuth>} />
            <Route path="/predictions" element={<RequireAuth><PredictionsPage /></RequireAuth>} />
            <Route path="/trades" element={<RequireAuth><TradeJournalPage /></RequireAuth>} />
            <Route path="/suggestions" element={<RequireAuth><SuggestionsPage /></RequireAuth>} />
            <Route path="/reports" element={<RequireAuth><ReportsPage /></RequireAuth>} />
            <Route path="/settings" element={<RequireAuth><SettingsPage /></RequireAuth>} />
            <Route path="*" element={<Navigate to="/" replace />} />
          </Routes>
        </BrowserRouter>
      </QueryClientProvider>
    </ErrorBoundary>
  )
}
