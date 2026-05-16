import { useQuery } from '@tanstack/react-query'
import { api } from '@/lib/api'

interface AuthStatus {
  authenticated: boolean
}

export function useAuth() {
  return useQuery<AuthStatus>({
    queryKey: ['auth', 'status'],
    queryFn: async () => (await api.get('/api/v1/auth/status')).data,
    retry: false,
    staleTime: 60_000,
  })
}
