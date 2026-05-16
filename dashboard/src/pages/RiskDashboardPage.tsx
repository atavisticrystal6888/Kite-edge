/** T112: Risk Dashboard Page. */
import { useRiskDashboard } from '@/hooks/useRiskDashboard'
import { RiskCards } from '@/components/risk/RiskCards'
import { DrawdownChart } from '@/components/risk/DrawdownChart'

export function RiskDashboardPage() {
  const { data, isLoading, error } = useRiskDashboard()

  if (isLoading) return <p className="p-6">Loading risk analytics…</p>
  if (error) return <p className="p-6 text-red-600">Failed to load risk data.</p>

  return (
    <div className="p-6 space-y-6">
      <h1 className="text-2xl font-semibold">Risk Dashboard</h1>
      <RiskCards ratios={data?.ratios ?? {}} />
      <DrawdownChart data={data?.drawdown?.details ?? []} />
    </div>
  )
}
