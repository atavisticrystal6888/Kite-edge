/** T184: Reports page + query hook. */
import { TearSheetViewer } from '@/components/reports/TearSheetViewer'
import { ExportCenter } from '@/components/reports/ExportCenter'
import { PowerBIConnectionGuide } from '@/components/reports/PowerBIConnectionGuide'
import { ReportDisclaimer } from '@/components/reports/ReportDisclaimer'

export function ReportsPage() {
  return (
    <div className="p-6 space-y-6">
      <h1 className="text-2xl font-semibold">Reports</h1>
      <ReportDisclaimer />
      <TearSheetViewer htmlContent={null} />
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <ExportCenter />
        <PowerBIConnectionGuide />
      </div>
    </div>
  )
}
