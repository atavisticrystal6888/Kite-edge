/** T130: Model accuracy leaderboard. */
export function ModelAccuracy({
  models,
}: {
  models: { name: string; mae: number; rmse: number; mape: number | null }[]
}) {
  return (
    <div className="border rounded-lg p-4" data-testid="model-accuracy">
      <h3 className="text-sm font-semibold mb-2">Model Accuracy</h3>
      <table className="w-full text-xs">
        <thead>
          <tr className="text-left text-slate-500 border-b">
            <th className="py-1">Model</th>
            <th>MAE</th>
            <th>RMSE</th>
            <th>MAPE %</th>
          </tr>
        </thead>
        <tbody>
          {models.map((m) => (
            <tr key={m.name} className="border-b">
              <td className="py-1 font-medium">{m.name}</td>
              <td>{m.mae.toFixed(4)}</td>
              <td>{m.rmse.toFixed(4)}</td>
              <td>{m.mape !== null ? m.mape.toFixed(2) : '—'}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}
