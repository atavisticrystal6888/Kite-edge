/**
 * Login page footer disclaimer (T055b, D1 remediation).
 * Rendered on every login surface per Constitution Principle 8.
 */
import { Disclaimer } from '@/components/shared/Disclaimer'

export function LoginFooterDisclaimer() {
  return (
    <footer className="mt-10 max-w-xl mx-auto" data-testid="login-footer">
      <Disclaimer variant="login" />
    </footer>
  )
}
