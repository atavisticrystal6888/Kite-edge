/** T198: Mobile-responsive layout rules. */
export const breakpoints = {
  sm: 640,
  md: 768,
  lg: 1024,
  xl: 1280,
} as const

export function useIsMobile(): boolean {
  if (typeof window === 'undefined') return false
  return window.innerWidth < breakpoints.md
}
