import React from 'react'
import { useTranslation } from 'react-i18next'
import { motion } from 'framer-motion'
import { Activity, HardDrive, Wifi, Users, RefreshCw, ScrollText, FolderOpen, Terminal } from 'lucide-react'

const PlaceholderPage: React.FC<{ title: string; icon: React.ReactNode; description?: string }> = ({ 
  title, 
  icon, 
  description = "This feature is coming soon" 
}) => {
  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      className="space-y-6"
    >
      <div className="flex items-center gap-3">
        <div className="p-2.5 bg-macos-accent/10 rounded-xl">
          {React.cloneElement(icon as React.ReactElement, { className: 'w-6 h-6 text-macos-accent' })}
        </div>
        <div>
          <h1 className="text-2xl font-semibold text-macos-primary dark:text-macos-dark-primary">
            {title}
          </h1>
          <p className="text-macos-secondary dark:text-macos-dark-secondary">
            {description}
          </p>
        </div>
      </div>

      <div className="macos-card p-12 text-center">
        <div className="w-20 h-20 bg-macos-sidebar dark:bg-macos-dark-sidebar rounded-full flex items-center justify-center mx-auto mb-4">
          {React.cloneElement(icon as React.ReactElement, { className: 'w-10 h-10 text-macos-tertiary' })}
        </div>
        <h2 className="text-lg font-semibold text-macos-primary dark:text-macos-dark-primary mb-2">
          Coming Soon
        </h2>
        <p className="text-sm text-macos-secondary dark:text-macos-dark-secondary max-w-md mx-auto">
          This feature is currently under development. Check back later for updates!
        </p>
      </div>
    </motion.div>
  )
}

export const ProcessesPage: React.FC = () => {
  const { t } = useTranslation()
  return <PlaceholderPage 
    title={t('navigation.processes')} 
    icon={<Activity />} 
    description="Monitor and manage running processes"
  />
}

export const StoragePage: React.FC = () => {
  const { t } = useTranslation()
  return <PlaceholderPage 
    title={t('navigation.storage')} 
    icon={<HardDrive />}
    description="Manage storage and disk usage"
  />
}

export const NetworkPage: React.FC = () => {
  const { t } = useTranslation()
  return <PlaceholderPage 
    title={t('navigation.network')} 
    icon={<Wifi />}
    description="Configure network settings"
  />
}

export const UsersPage: React.FC = () => {
  const { t } = useTranslation()
  return <PlaceholderPage 
    title={t('navigation.users')} 
    icon={<Users />}
    description="Manage user accounts"
  />
}

export const SoftwareUpdatePage: React.FC = () => {
  const { t } = useTranslation()
  return <PlaceholderPage 
    title={t('navigation.updates')} 
    icon={<RefreshCw />}
    description="Check for system updates"
  />
}

export const LogsPage: React.FC = () => {
  const { t } = useTranslation()
  return <PlaceholderPage 
    title={t('navigation.logs')} 
    icon={<ScrollText />}
    description="View system logs"
  />
}

export const FileBrowserPage: React.FC = () => {
  const { t } = useTranslation()
  return <PlaceholderPage 
    title={t('navigation.files')} 
    icon={<FolderOpen />}
    description="Browse files and folders"
  />
}

export const TerminalPage: React.FC = () => {
  const { t } = useTranslation()
  return <PlaceholderPage 
    title={t('navigation.terminal')} 
    icon={<Terminal />}
    description="Access command line"
  />
}
