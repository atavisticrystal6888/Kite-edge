/** T169: Alert configuration and toast delivery wiring. */
import { useState } from 'react'
import { useMutation, useQueryClient } from '@tanstack/react-query'
import { api } from '@/lib/api'

export function AlertConfig() {
  const [symbol, setSymbol] = useState('')
  const [type, setType] = useState('price_above')
  const [value, setValue] = useState('')
  const queryClient = useQueryClient()

  const addAlert = useMutation({
    mutationFn: async (rule: { symbol: string; condition: string; value: number }) =>
      (await api.post('/api/v1/analytics/alerts', rule)).data,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['alerts'] })
      setSymbol('')
      setValue('')
    },
  })

  const handleAdd = () => {
    if (!symbol || !value) return
    addAlert.mutate({ symbol, condition: type, value: parseFloat(value) })
  }

  return (
    <div className="border rounded-lg p-4" data-testid="alert-config">
      <h3 className="text-sm font-semibold mb-2">Alert Rules</h3>
      <div className="flex gap-2 mb-3">
        <input type="text" placeholder="Symbol" value={symbol} onChange={(e) => setSymbol(e.target.value)} className="border rounded px-2 py-1 text-sm w-28" />
        <select value={type} onChange={(e) => setType(e.target.value)} className="border rounded px-2 py-1 text-sm">
          <option value="price_above">Price Above</option>
          <option value="price_below">Price Below</option>
          <option value="pct_change">% Change</option>
        </select>
        <input type="number" placeholder="Value" value={value} onChange={(e) => setValue(e.target.value)} className="border rounded px-2 py-1 text-sm w-24" />
        <button onClick={handleAdd} disabled={addAlert.isPending} className="bg-blue-600 text-white text-sm px-3 py-1 rounded disabled:opacity-50">Add</button>
      </div>
    </div>
  )
}
