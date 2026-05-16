/** T167: Rebalancing calculator. */
export function Rebalancer({
  actions,
}: {
  actions: { symbol: string; current_weight: number; target_weight: number; action: string; adjustment_value: number }[]
}) {
  return (
    <div className="border rounded-lg p-4" data-testid="rebalancer">
      <h3 className="text-sm font-semibold mb-2">Rebalance Recommendations</h3>
      <table className="w-full text-xs">
        <thead>
          <tr className="text-left text-slate-500 border-b">
            <th className="py-1">Symbol</th>
            <th>Current</th>
            <th>Target</th>
            <th>Action</th>
            <th>Amount</th>
          </tr>
        </thead>
        <tbody>
          {actions.map((a) => (
            <tr key={a.symbol} className="border-b">
              <td className="py-1 font-medium">{a.symbol}</td>
              <td>{(a.current_weight * 100).toFixed(1)}%</td>
              <td>{(a.target_weight * 100).toFixed(1)}%</td>
              <td className={a.action === 'buy' ? 'text-green-600' : 'text-red-600'}>{a.action.toUpperCase()}</td>
              <td>₹{a.adjustment_value.toFixed(0)}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}
