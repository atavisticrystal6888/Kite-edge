/** T181: Tear sheet viewer. */
export function TearSheetViewer({ htmlContent }: { htmlContent: string | null }) {
  if (!htmlContent) return <p className="text-sm text-slate-400">No tear sheet generated yet.</p>

  return (
    <div className="border rounded-lg p-4" data-testid="tearsheet-viewer">
      <iframe title="Tear Sheet" srcDoc={htmlContent} className="w-full h-[600px] border-0" sandbox="allow-same-origin" />
    </div>
  )
}
