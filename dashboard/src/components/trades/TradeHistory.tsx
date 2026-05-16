/** T147: Trade history table. */
export function TradeHistory({
  trades,
}: {
  trades: { trade_id: string; symbol: string; side: string; quantity: number; price: number; pnl_absolute: number; executed_at: string }[]
}) {
  return (
    <table className="w-full text-sm" data-testid="trade-history">
      <thead>
        <tr className="text-left text-slate-500 border-b">
          <th className="py-2">Symbol</th>
          <th>Side</th>
          <th>Qty</th>
          <th>Price</th>
          <th>P&amp;L</th>
          <th>Date</th>
        </tr>
      </thead>
      <tbody>
        {trades.map((t) => (
          <tr key={t.trade_id} className="border-b">
            <td className="py-2 font-medium">{t.symbol}</td>
            <td className={t.side === 'BUY' ? 'text-green-600' : 'text-red-600'}>{t.side}</td>
            <td>{t.quantity}</td>
            <td>{t.price.toFixed(2)}</td>
            <td className={t.pnl_absolute >= 0 ? 'text-green-600' : 'text-red-600'}>{t.pnl_absolute.toFixed(2)}</td>
            <td className="text-slate-400">{t.executed_at}</td>
          </tr>
        ))}
      </tbody>
    </table>
  )
}
