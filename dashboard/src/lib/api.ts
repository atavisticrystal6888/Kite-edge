import axios from 'axios'

export const api = axios.create({
  baseURL: import.meta.env.VITE_GATEWAY_URL ?? 'http://localhost:4000',
  withCredentials: true,
})

api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      window.location.href = '/'
    }
    return Promise.reject(error)
  },
)
