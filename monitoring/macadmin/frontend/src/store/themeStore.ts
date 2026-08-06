import { create } from 'zustand'
import { persist } from 'zustand/middleware'

interface ThemeState {
  theme: 'light' | 'dark' | 'auto'
  isDark: boolean
  accentColor: string
  setTheme: (theme: 'light' | 'dark' | 'auto') => void
  initializeTheme: () => void
  setAccentColor: (color: string) => void
}

export const useThemeStore = create<ThemeState>()(
  persist(
    (set, get) => ({
      theme: 'auto',
      isDark: false,
      accentColor: 'blue',

      setTheme: (theme) => {
        const isDark = theme === 'dark' || 
          (theme === 'auto' && window.matchMedia('(prefers-color-scheme: dark)').matches)
        
        set({ theme, isDark })
        
        if (isDark) {
          document.documentElement.classList.add('dark')
        } else {
          document.documentElement.classList.remove('dark')
        }
      },

      initializeTheme: () => {
        const { theme } = get()
        const isDark = theme === 'dark' || 
          (theme === 'auto' && window.matchMedia('(prefers-color-scheme: dark)').matches)
        
        set({ isDark })
        
        if (isDark) {
          document.documentElement.classList.add('dark')
        } else {
          document.documentElement.classList.remove('dark')
        }

        if (theme === 'auto') {
          window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', (e) => {
            set({ isDark: e.matches })
            if (e.matches) {
              document.documentElement.classList.add('dark')
            } else {
              document.documentElement.classList.remove('dark')
            }
          })
        }
      },

      setAccentColor: (color) => set({ accentColor: color }),
    }),
    {
      name: 'macadmin-theme',
    }
  )
)
