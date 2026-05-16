/**
 * T080: Indicator configuration panel.
 */
import { useIndicatorProfile, useUpdateProfile, useResetProfile } from '@/hooks/useSettings'
import { useState } from 'react'

export function IndicatorConfigPanel() {
  const { data: profile } = useIndicatorProfile()
  const update = useUpdateProfile()
  const reset = useResetProfile()
  const [editing, setEditing] = useState(false)
  const [params, setParams] = useState<Record<string, unknown>>({})

  const handleSave = () => {
    update.mutate({ parameters: params })
    setEditing(false)
  }

  return (
    <div className="border rounded-lg p-4" data-testid="indicator-config">
      <div className="flex justify-between items-center mb-2">
        <h3 className="text-sm font-semibold">Indicator Profile: {profile?.name ?? 'default'}</h3>
        <div className="flex gap-2">
          <button onClick={() => setEditing(!editing)} className="text-xs text-blue-600 hover:underline">
            {editing ? 'Cancel' : 'Edit'}
          </button>
          <button onClick={() => reset.mutate()} className="text-xs text-red-600 hover:underline">
            Reset
          </button>
        </div>
      </div>
      {editing && (
        <div className="space-y-2">
          <textarea
            className="w-full text-xs border rounded p-2 h-24 font-mono"
            value={JSON.stringify(params, null, 2)}
            onChange={(e) => {
              try { setParams(JSON.parse(e.target.value)) } catch { /* ignore */ }
            }}
          />
          <button onClick={handleSave} className="text-xs bg-blue-600 text-white px-3 py-1 rounded">
            Save
          </button>
        </div>
      )}
      {!editing && profile?.parameters && (
        <pre className="text-xs text-slate-500 mt-2">{JSON.stringify(profile.parameters, null, 2)}</pre>
      )}
    </div>
  )
}
