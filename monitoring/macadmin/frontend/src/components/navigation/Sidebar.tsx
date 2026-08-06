import React from 'react'
import { useTranslation } from 'react-i18next'
import { NavLink, useLocation } from 'react-router-dom'
import { motion } from 'framer-motion'
import {
  LayoutDashboard,
  Activity,
  HardDrive,
  Wifi,
  Users,
  RefreshCw,
  ScrollText,
  FolderOpen,
  Terminal,
  Settings,
  Apple,
  Package
} from 'lucide-react'

interface MenuSection {
  title: string
  items: { path: string; label: string; icon: React.ReactNode }[]
}

const Sidebar: React.FC = () => {
  const { t } = useTranslation()
  const location = useLocation()

  const menuSections: MenuSection[] = [
    {
      title: t('navigation.overview'),
      items: [
        { path: '/dashboard', label: t('navigation.dashboard'), icon: <LayoutDashboard className="w-5 h-5" /> },
      ]
    },
    {
      title: t('navigation.system'),
      items: [
        { path: '/system/processes', label: t('navigation.processes'), icon: <Activity className="w-5 h-5" /> },
        { path: '/system/storage', label: t('navigation.storage'), icon: <HardDrive className="w-5 h-5" /> },
        { path: '/system/network', label: t('navigation.network'), icon: <Wifi className="w-5 h-5" /> },
        { path: '/system/users', label: t('navigation.users'), icon: <Users className="w-5 h-5" /> },
        { path: '/system/updates', label: t('navigation.updates'), icon: <RefreshCw className="w-5 h-5" /> },
        { path: '/system/logs', label: t('navigation.logs'), icon: <ScrollText className="w-5 h-5" /> },
      ]
    },
    {
      title: t('navigation.tools'),
      items: [
        { path: '/tools/files', label: t('navigation.files'), icon: <FolderOpen className="w-5 h-5" /> },
        { path: '/tools/terminal', label: t('navigation.terminal'), icon: <Terminal className="w-5 h-5" /> },
        { path: '/tools/brew', label: 'Homebrew', icon: <Package className="w-5 h-5" /> },
      ]
    },
  ]

  return (
    <motion.aside
      initial={{ x: -260 }}
      animate={{ x: 0 }}
      className="w-64 h-screen macos-sidebar flex flex-col"
    >
      {/* Logo */}
      <div className="p-4 border-b border-macos-quaternary/20">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-macos-accent rounded-xl flex items-center justify-center">
            <Apple className="w-6 h-6 text-white" />
          </div>
          <div>
            <h1 className="font-semibold text-lg text-macos-primary dark:text-macos-dark-primary">
              {t('app.name')}
            </h1>
            <p className="text-xs text-macos-secondary dark:text-macos-dark-secondary">
              {t('app.tagline')}
            </p>
          </div>
        </div>
      </div>

      {/* Navigation */}
      <nav className="flex-1 overflow-y-auto p-3 space-y-6">
        {menuSections.map((section) => (
          <div key={section.title}>
            <h3 className="px-3 text-xs font-semibold text-macos-tertiary dark:text-macos-dark-tertiary uppercase tracking-wider mb-2">
              {section.title}
            </h3>
            <ul className="space-y-0.5">
              {section.items.map((item) => (
                <li key={item.path}>
                  <NavLink
                    to={item.path}
                    className={({ isActive }) =>
                      `macos-list-item ${isActive ? 'active' : ''}`
                    }
                  >
                    {item.icon}
                    <span className="font-medium">{item.label}</span>
                  </NavLink>
                </li>
              ))}
            </ul>
          </div>
        ))}
      </nav>

      {/* Bottom Actions */}
      <div className="p-3 border-t border-macos-quaternary/20">
        <NavLink
          to="/settings"
          className={({ isActive }) =>
            `macos-list-item ${isActive ? 'active' : ''}`
          }
        >
          <Settings className="w-5 h-5" />
          <span className="font-medium">{t('navigation.settings')}</span>
        </NavLink>
      </div>
    </motion.aside>
  )
}

export default Sidebar
