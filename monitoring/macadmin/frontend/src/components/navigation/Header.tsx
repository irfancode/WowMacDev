import React from 'react'
import { useTranslation } from 'react-i18next'
import { useAuthStore } from '../../store/authStore'
import { useThemeStore } from '../../store/themeStore'
import { Moon, Sun, Bell, Search, User } from 'lucide-react'

const Header: React.FC = () => {
  const { t } = useTranslation()
  const { user, logout } = useAuthStore()
  const { theme, setTheme, isDark } = useThemeStore()

  const handleLogout = async () => {
    await logout()
  }

  return (
    <header className="macos-toolbar">
      {/* Left side */}
      <div className="flex items-center gap-4">
        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-macos-tertiary" />
          <input
            type="text"
            placeholder="Search"
            className="w-64 pl-9 pr-4 py-1.5 bg-macos-content/50 dark:bg-macos-dark-content/50 
                     border border-macos-quaternary/30 rounded-lg text-sm
                     focus:outline-none focus:ring-2 focus:ring-macos-accent/20
                     placeholder:text-macos-tertiary"
          />
        </div>
      </div>

      {/* Right side */}
      <div className="flex items-center gap-2">
        {/* Theme Toggle */}
        <button
          onClick={() => setTheme(isDark ? 'light' : 'dark')}
          className="p-2 rounded-lg hover:bg-macos-sidebar/50 dark:hover:bg-macos-dark-sidebar/50 transition-colors"
          title={isDark ? 'Light Mode' : 'Dark Mode'}
        >
          {isDark ? (
            <Sun className="w-5 h-5 text-macos-dark-primary" />
          ) : (
            <Moon className="w-5 h-5 text-macos-primary" />
          )}
        </button>

        {/* Notifications */}
        <button className="p-2 rounded-lg hover:bg-macos-sidebar/50 dark:hover:bg-macos-dark-sidebar/50 transition-colors relative">
          <Bell className="w-5 h-5 text-macos-secondary dark:text-macos-dark-secondary" />
          <span className="absolute top-1.5 right-1.5 w-2 h-2 bg-macos-accent-red rounded-full" />
        </button>

        {/* User Menu */}
        <div className="flex items-center gap-3 pl-3 border-l border-macos-quaternary/20">
          <div className="text-right hidden sm:block">
            <p className="text-sm font-medium text-macos-primary dark:text-macos-dark-primary">
              {user?.fullName || user?.username}
            </p>
            <p className="text-xs text-macos-secondary dark:text-macos-dark-secondary">
              {user?.isAdmin ? 'Administrator' : 'Standard'}
            </p>
          </div>
          <div className="w-8 h-8 bg-macos-accent/10 rounded-full flex items-center justify-center">
            <User className="w-4 h-4 text-macos-accent" />
          </div>
        </div>
      </div>
    </header>
  )
}

export default Header
