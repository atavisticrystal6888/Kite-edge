/** T183: Power BI Connection Guide. */
export function PowerBIConnectionGuide() {
  return (
    <div className="border rounded-lg p-4" data-testid="powerbi-guide">
      <h3 className="text-sm font-semibold mb-2">Power BI / OData Connection</h3>
      <ol className="text-xs text-slate-600 space-y-2 list-decimal list-inside">
        <li>Open Power BI Desktop → Get Data → OData Feed.</li>
        <li>Enter the OData URL: <code className="bg-slate-100 px-1 py-0.5 rounded">/api/v1/reports/odata/holdings</code></li>
        <li>Select "Holdings" entity → Load.</li>
        <li>For streaming: use the Power BI Push endpoint <code className="bg-slate-100 px-1 py-0.5 rounded">/api/v1/reports/powerbi/push</code></li>
        <li>Configure scheduled refresh in Power BI Service as needed.</li>
      </ol>
    </div>
  )
}
