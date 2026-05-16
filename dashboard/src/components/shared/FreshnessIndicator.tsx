/** T197: Shared freshness badge. */
export function FreshnessIndicator({ freshness }: { freshness: 'live' | 'stale' | 'offline' }) {
  const styles = {
    live: 'bg-green-50 text-green-700',
    stale: 'bg-amber-50 text-amber-700',
    offline: 'bg-red-50 text-red-700',
  }
  return (
    <span className={`text-xs px-2 py-1 rounded ${styles[freshness]}`} data-testid="freshness-badge">
      {freshness.toUpperCase()}
    </span>
  )
}
