/** T149: P&L Calendar heatmap. */
export function PLCalendar({ data }: { data: { date: string; pnl: number }[] }) {
  return (
    <div className="border rounded-lg p-4" data-testid="pl-calendar">
      <h3 className="text-sm font-semibold mb-2">P&amp;L Calendar</h3>
      <div className="grid grid-cols-7 gap-1">
        {data.map((d) => (
          <div
            key={d.date}
            title={`${d.date}: ${d.pnl.toFixed(2)}`}
            className={`w-6 h-6 rounded text-[8px] flex items-center justify-center ${
              d.pnl > 0 ? 'bg-green-100 text-green-800' : d.pnl < 0 ? 'bg-red-100 text-red-800' : 'bg-slate-50'
            }`}
          >
            {d.pnl !== 0 ? (d.pnl > 0 ? '+' : '−') : ''}
          </div>
        ))}
      </div>
    </div>
  )
}
