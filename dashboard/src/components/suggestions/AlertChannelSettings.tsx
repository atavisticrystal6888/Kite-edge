/** T169c: Alert channel settings (email/in-app). */
export function AlertChannelSettings() {
  return (
    <div className="border rounded-lg p-4" data-testid="alert-channels">
      <h3 className="text-sm font-semibold mb-2">Notification Channels</h3>
      <label className="flex items-center gap-2 text-sm">
        <input type="checkbox" defaultChecked /> In-app notifications
      </label>
      <label className="flex items-center gap-2 text-sm mt-2">
        <input type="checkbox" /> Email alerts
      </label>
    </div>
  )
}
