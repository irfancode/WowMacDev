import { useQuery } from '@tanstack/react-query'
import axios from 'axios'

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000'

const api = axios.create({
  baseURL: `${API_URL}/api`,
  headers: {
    'Content-Type': 'application/json',
  },
})

api.interceptors.request.use((config) => {
  const token = localStorage.getItem('macadmin-auth')
  if (token) {
    try {
      const { accessToken } = JSON.parse(token)
      if (accessToken) {
        config.headers.Authorization = `Bearer ${accessToken}`
      }
    } catch (e) {
      console.error('Failed to parse auth token')
    }
  }
  return config
})

export function useSystemMetrics() {
  return useQuery({
    queryKey: ['system', 'metrics'],
    queryFn: async () => {
      const { data } = await api.get('/system/metrics')
      return data
    },
    refetchInterval: 5000,
  })
}

export function useSystemInfo() {
  return useQuery({
    queryKey: ['system', 'info'],
    queryFn: async () => {
      const { data } = await api.get('/system/info')
      return data
    },
    staleTime: 60 * 1000,
  })
}

export function useTopProcesses() {
  return useQuery({
    queryKey: ['system', 'processes', 'top'],
    queryFn: async () => {
      const { data } = await api.get('/processes')
      return data
    },
    refetchInterval: 5000,
  })
}

export function useAvailableUpdates() {
  return useQuery({
    queryKey: ['system', 'updates'],
    queryFn: async () => {
      const { data } = await api.get('/updates')
      return data
    },
    refetchInterval: 60 * 60 * 1000,
  })
}

export function formatBytes(bytes: number): string {
  if (!bytes || bytes <= 0) return '0 B'
  const units = ['B', 'KB', 'MB', 'GB', 'TB']
  const i = Math.min(Math.floor(Math.log(bytes) / Math.log(1024)), units.length - 1)
  return `${(bytes / Math.pow(1024, i)).toFixed(1)} ${units[i]}`
}

export function formatSpeed(bytesPerSecond: number): string {
  return `${formatBytes(bytesPerSecond)}/s`
}
