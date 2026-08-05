import React, { useEffect } from 'react'
import { Routes, Route, Navigate } from 'react-router-dom'
import { useThemeStore } from './store/themeStore'
import { useAuthStore } from './store/authStore'

import MainLayout from './components/layouts/MainLayout'
import AuthLayout from './components/layouts/AuthLayout'

import LoginPage from './pages/auth/LoginPage'
import DashboardPage from './pages/dashboard/DashboardPage'
import ProcessesPage from './pages/system/ProcessesPage'
import StoragePage from './pages/system/StoragePage'
import NetworkPage from './pages/system/NetworkPage'
import UsersPage from './pages/system/UsersPage'
import SoftwareUpdatePage from './pages/system/SoftwareUpdatePage'
import LogsPage from './pages/system/LogsPage'
import FileBrowserPage from './pages/tools/FileBrowserPage'
import TerminalPage from './pages/tools/TerminalPage'
import BrewManagerPage from './pages/tools/BrewManagerPage'
import SettingsPage from './pages/settings/SettingsPage'

import ProtectedRoute from './components/auth/ProtectedRoute'
import LoadingScreen from './components/common/LoadingScreen'

function App() {
  const { theme, initializeTheme } = useThemeStore()
  const { checkAuth, isLoading } = useAuthStore()

  useEffect(() => {
    initializeTheme()
    checkAuth()
  }, [])

  if (isLoading) {
    return <LoadingScreen />
  }

  return (
    <div className={theme}>
      <div className="min-h-screen bg-macos-window dark:bg-macos-dark-window transition-colors duration-200">
        <Routes>
          <Route element={<AuthLayout />}>
            <Route path="/login" element={<LoginPage />} />
          </Route>

          <Route element={<ProtectedRoute />}>
            <Route element={<MainLayout />}>
              <Route path="/" element={<Navigate to="/dashboard" replace />} />
              <Route path="/dashboard" element={<DashboardPage />} />
              
              <Route path="/system/processes" element={<ProcessesPage />} />
              <Route path="/system/storage" element={<StoragePage />} />
              <Route path="/system/network" element={<NetworkPage />} />
              <Route path="/system/users" element={<UsersPage />} />
              <Route path="/system/updates" element={<SoftwareUpdatePage />} />
              <Route path="/system/logs" element={<LogsPage />} />
              
              <Route path="/tools/files" element={<FileBrowserPage />} />
              <Route path="/tools/terminal" element={<TerminalPage />} />
              <Route path="/tools/brew" element={<BrewManagerPage />} />
              
              <Route path="/settings" element={<SettingsPage />} />
            </Route>
          </Route>

          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </div>
    </div>
  )
}

export default App
