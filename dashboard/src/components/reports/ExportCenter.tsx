/** T182, T182a: Export center with PDF, Excel, CSV options. */
import { api } from '@/lib/api'
import { useState } from 'react'

const FORMATS = ['xlsx', 'csv', 'pdf'] as const

export function ExportCenter() {
  const [format, setFormat] = useState<(typeof FORMATS)[number]>('xlsx')
  const [status, setStatus] = useState<string | null>(null)

  const handleExport = async () => {
    setStatus('Generating…')
    try {
      const res = await api.post('/api/v1/reports/export', { scope_type: 'portfolio', format })
      setStatus(`Export queued: ${res.data.export_job_id ?? 'pending'}`)
    } catch {
      setStatus('Export failed.')
    }
  }

  return (
    <div className="border rounded-lg p-4" data-testid="export-center">
      <h3 className="text-sm font-semibold mb-2">Export Data</h3>
      <div className="flex gap-2">
        <select value={format} onChange={(e) => setFormat(e.target.value as typeof format)} className="border rounded px-2 py-1 text-sm">
          {FORMATS.map((f) => (
            <option key={f} value={f}>{f.toUpperCase()}</option>
          ))}
        </select>
        <button onClick={handleExport} className="bg-blue-600 text-white text-sm px-3 py-1 rounded">Export</button>
      </div>
      {status && <p className="text-xs text-slate-500 mt-2">{status}</p>}
    </div>
  )
}
