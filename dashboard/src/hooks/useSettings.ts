import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { api } from '@/lib/api'

export function useIndicatorProfile() {
  return useQuery({
    queryKey: ['settings', 'indicator-profile'],
    queryFn: async () => (await api.get('/api/v1/settings/indicator-profile')).data.data,
  })
}

export function useUpdateProfile() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: async (params: Record<string, unknown>) =>
      (await api.put('/api/v1/settings/indicator-profile', params)).data,
    onSuccess: () => qc.invalidateQueries({ queryKey: ['settings'] }),
  })
}

export function useResetProfile() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: async () => (await api.delete('/api/v1/settings/indicator-profile')).data,
    onSuccess: () => qc.invalidateQueries({ queryKey: ['settings'] }),
  })
}
