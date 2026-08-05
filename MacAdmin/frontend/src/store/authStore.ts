import { create } from 'zustand'
import { persist } from 'zustand/middleware'

interface User {
  id: string
  username: string
  fullName: string
  role: 'admin' | 'standard'
  isAdmin: boolean
}

interface AuthState {
  user: User | null
  isAuthenticated: boolean
  isLoading: boolean
  accessToken: string | null
  
  login: (username: string, password: string) => Promise<void>
  logout: () => Promise<void>
  checkAuth: () => Promise<void>
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set, get) => ({
      user: null,
      isAuthenticated: false,
      isLoading: true,
      accessToken: null,

      login: async (username: string, password: string) => {
        try {
          const response = await fetch(`${import.meta.env.VITE_API_URL}/api/auth/login`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ username, password }),
          })

          if (!response.ok) {
            throw new Error('Login failed')
          }

          const data = await response.json()
          
          set({
            user: data.user,
            isAuthenticated: true,
            accessToken: data.access_token,
          })
        } catch (error) {
          console.error('Login error:', error)
          throw error
        }
      },

      logout: async () => {
        set({
          user: null,
          isAuthenticated: false,
          accessToken: null,
        })
      },

      checkAuth: async () => {
        try {
          const { accessToken } = get()
          
          if (!accessToken) {
            set({ isLoading: false })
            return
          }

          const response = await fetch(`${import.meta.env.VITE_API_URL}/api/auth/me`, {
            headers: { 'Authorization': `Bearer ${accessToken}` },
          })

          if (response.ok) {
            const user = await response.json()
            set({ user, isAuthenticated: true, isLoading: false })
          } else {
            set({ isLoading: false })
          }
        } catch (error) {
          set({ isLoading: false })
        }
      },
    }),
    {
      name: 'macadmin-auth',
      partialize: (state) => ({ accessToken: state.accessToken }),
    }
  )
)
