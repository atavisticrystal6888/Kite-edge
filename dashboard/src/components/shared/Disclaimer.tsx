/**
 * Shared legal disclaimer component (T055a, D1 remediation).
 *
 * Per constitution Principle 8, every prediction page, every suggestion page,
 * every report, AND the login page footer MUST render this disclaimer text.
 * Variants tune the wording for context but the core risk language is fixed.
 */
import type { ReactNode } from 'react'

export type DisclaimerVariant = 'login' | 'prediction' | 'suggestion' | 'report'

const BASE_TEXT =
  'KiteEdge is a personal research tool. It does not provide investment advice, ' +
  'does not execute trades, and does not guarantee outcomes. Markets involve risk, ' +
  'including loss of capital. Verify all figures independently before making any decision.'

const VARIANT_TEXT: Record<DisclaimerVariant, string> = {
  login: `${BASE_TEXT} By continuing you acknowledge these terms.`,
  prediction:
    `${BASE_TEXT} Forecasts on this page are statistical projections, ` +
    'not recommendations, and will be wrong sometimes.',
  suggestion:
    `${BASE_TEXT} Suggested actions are heuristic screens, ` +
    'not financial advice. Past performance does not predict future results.',
  report:
    `${BASE_TEXT} Report figures are derived from your own Kite history and ` +
    'may include rounding or reconciliation differences.',
}

export function Disclaimer({
  variant,
  className,
  children,
}: {
  variant: DisclaimerVariant
  className?: string
  children?: ReactNode
}) {
  return (
    <div
      role="note"
      aria-label={`${variant} disclaimer`}
      data-testid={`disclaimer-${variant}`}
      className={className ?? 'text-xs leading-5 text-slate-500 border-t border-slate-200 pt-3 mt-3'}
    >
      <strong className="block text-slate-600 mb-1">Disclaimer</strong>
      <p>{VARIANT_TEXT[variant]}</p>
      {children}
    </div>
  )
}
