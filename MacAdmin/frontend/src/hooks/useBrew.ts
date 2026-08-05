import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import axios from 'axios'

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000'

const api = axios.create({
  baseURL: `${API_URL}/api`,
  headers: {
    'Content-Type': 'application/json',
  },
})

// Add auth token to requests
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

// Check CLI Tools
export function useCheckCLITools() {
  return useQuery({
    queryKey: ['brew', 'cli-tools'],
    queryFn: async () => {
      const { data } = await api.get('/brew/check-cli-tools')
      return data
    },
  })
}

// Install CLI Tools
export function useInstallCLITools() {
  const queryClient = useQueryClient()
  return useMutation({
    mutationFn: async () => {
      const { data } = await api.post('/brew/install-cli-tools')
      return data
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['brew', 'cli-tools'] })
    },
  })
}

// Check Homebrew
export function useCheckBrew() {
  return useQuery({
    queryKey: ['brew', 'brew-installed'],
    queryFn: async () => {
      const { data } = await api.get('/brew/check-brew')
      return data
    },
  })
}

// Install Homebrew
export function useInstallBrew() {
  const queryClient = useQueryClient()
  return useMutation({
    mutationFn: async () => {
      const { data } = await api.post('/brew/install-brew')
      return data
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['brew', 'brew-installed'] })
    },
  })
}

// Get Brew Packages
export function useBrewPackages() {
  return useQuery({
    queryKey: ['brew', 'packages'],
    queryFn: async () => {
      const { data } = await api.get('/brew/packages')
      return data
    },
  })
}

// Get Brew Casks
export function useBrewCasks() {
  return useQuery({
    queryKey: ['brew', 'casks'],
    queryFn: async () => {
      const { data } = await api.get('/brew/casks')
      return data
    },
  })
}

// Install Package
export function useInstallPackage() {
  const queryClient = useQueryClient()
  return useMutation({
    mutationFn: async (packageName: string) => {
      const { data } = await api.post(`/brew/install/${packageName}`)
      return data
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['brew'] })
    },
  })
}

// Install Cask
export function useInstallCask() {
  const queryClient = useQueryClient()
  return useMutation({
    mutationFn: async (caskName: string) => {
      const { data } = await api.post(`/brew/install-cask/${caskName}`)
      return data
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['brew'] })
    },
  })
}

// Get Installed Packages
export function useInstalledPackages() {
  return useQuery({
    queryKey: ['brew', 'installed'],
    queryFn: async () => {
      const { data } = await api.get('/brew/installed')
      return data
    },
  })
}

// Update Brew
export function useUpdateBrew() {
  const queryClient = useQueryClient()
  return useMutation({
    mutationFn: async () => {
      const { data } = await api.post('/brew/update')
      return data
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['brew'] })
    },
  })
}

// Cleanup Brew
export function useCleanupBrew() {
  const queryClient = useQueryClient()
  return useMutation({
    mutationFn: async () => {
      const { data } = await api.post('/brew/cleanup')
      return data
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['brew'] })
    },
  })
}

// Uninstall Package
export function useUninstallPackage() {
  const queryClient = useQueryClient()
  return useMutation({
    mutationFn: async (packageName: string) => {
      const { data } = await api.post(`/brew/uninstall/${packageName}`)
      return data
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['brew'] })
    },
  })
}
