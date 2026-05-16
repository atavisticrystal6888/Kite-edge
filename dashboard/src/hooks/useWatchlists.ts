import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { api } from '@/lib/api'

export function useWatchlists() {
  return useQuery({
    queryKey: ['watchlists'],
    queryFn: async () => (await api.get('/api/v1/watchlists')).data.data,
  })
}

export function useCreateWatchlist() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: async (data: { name: string; symbols: string[] }) => (await api.post('/api/v1/watchlists', data)).data,
    onSuccess: () => qc.invalidateQueries({ queryKey: ['watchlists'] }),
  })
}

export function useDeleteWatchlist() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: async (id: number) => (await api.delete(`/api/v1/watchlists/${id}`)).data,
    onSuccess: () => qc.invalidateQueries({ queryKey: ['watchlists'] }),
  })
}
