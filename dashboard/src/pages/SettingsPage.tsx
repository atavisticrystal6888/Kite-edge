/** T083b: Settings page. */
import { IndicatorConfigPanel } from '@/components/technical/IndicatorConfigPanel'
import { AlertChannelSettings } from '@/components/suggestions/AlertChannelSettings'
import { WatchlistManager } from '@/components/suggestions/WatchlistManager'

export function SettingsPage() {
  return (
    <div className="p-6 space-y-6">
      <h1 className="text-2xl font-semibold">Settings</h1>
      <IndicatorConfigPanel />
      <AlertChannelSettings />
      <WatchlistManager />
    </div>
  )
}
