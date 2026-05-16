/** T184: Reports page + query hook. */
import { useQuery } from '@tanstack/react-query'
import { api } from '@/lib/api'
import { TearSheetViewer } from '@/components/reports/TearSheetViewer'
import { ExportCenter } from '@/components/reports/ExportCenter'
import { PowerBIConnectionGuide } from '@/components/reports/PowerBIConnectionGuide'
import { ReportDisclaimer } from '@/components/reports/ReportDisclaimer'

function useTearSheet() {
  return useQuery({
    queryKey: ['reports', 'tearsheet'],
    queryFn: async () => (await api.get('/api/v1/reports/tearsheet')).data,
    retry: false,
  })
}

export function ReportsPage() {
  const { data: tearsheet } = useTearSheet()

  return (
    <div className="p-6 space-y-6">
      <h1 className="text-2xl font-semibold">Reports</h1>
      <ReportDisclaimer />
      <TearSheetViewer htmlContent={tearsheet?.html ?? null} />
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <ExportCenter />
        <PowerBIConnectionGuide />
      </div>
    </div>
  )
}
