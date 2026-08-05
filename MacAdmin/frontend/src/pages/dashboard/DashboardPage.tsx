import React from 'react'
import { useTranslation } from 'react-i18next'
import { motion } from 'framer-motion'
import { 
  Cpu, 
  HardDrive, 
  Wifi, 
  Activity,
  CheckCircle2,
  AlertCircle,
  Clock,
  RefreshCw
} from 'lucide-react'

const DashboardPage: React.FC = () => {
  const { t } = useTranslation()

  const stats = [
    {
      title: t('dashboard.cpu'),
      value: '12%',
      subtitle: '8 cores',
      icon: <Cpu className="w-5 h-5" />,
      color: 'bg-macos-accent-blue',
    },
    {
      title: t('dashboard.memory'),
      value: '8.2 GB',
      subtitle: 'of 16 GB',
      icon: <Activity className="w-5 h-5" />,
      color: 'bg-macos-accent-green',
    },
    {
      title: t('dashboard.disk'),
      value: '245 GB',
      subtitle: 'of 1 TB',
      icon: <HardDrive className="w-5 h-5" />,
      color: 'bg-macos-accent-orange',
    },
    {
      title: t('dashboard.network'),
      value: '2.4 MB/s',
      subtitle: 'Download',
      icon: <Wifi className="w-5 h-5" />,
      color: 'bg-macos-accent-purple',
    },
  ]

  const processes = [
    { name: 'Safari', cpu: '5.2%', memory: '412 MB', icon: '🌐' },
    { name: 'Xcode', cpu: '12.8%', memory: '1.2 GB', icon: '🔨' },
    { name: 'Docker', cpu: '3.1%', memory: '856 MB', icon: '🐳' },
    { name: 'Spotify', cpu: '1.4%', memory: '234 MB', icon: '🎵' },
    { name: 'Terminal', cpu: '0.8%', memory: '45 MB', icon: '💻' },
  ]

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      className="space-y-6"
    >
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-semibold text-macos-primary dark:text-macos-dark-primary">
            {t('dashboard.title')}
          </h1>
          <p className="text-macos-secondary dark:text-macos-dark-secondary mt-1">
            {t('dashboard.overview')}
          </p>
        </div>
        <div className="flex items-center gap-2 px-3 py-1.5 bg-macos-accent-green/10 rounded-full">
          <CheckCircle2 className="w-4 h-4 text-macos-accent-green" />
          <span className="text-sm font-medium text-macos-accent-green">
            {t('dashboard.healthy')}
          </span>
        </div>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        {stats.map((stat, index) => (
          <motion.div
            key={stat.title}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: index * 0.1 }}
            className="macos-card p-5 hover:shadow-lg transition-shadow cursor-pointer"
          >
            <div className="flex items-start justify-between">
              <div className={`p-2.5 rounded-xl ${stat.color}/10`}>
                <div className={`${stat.color.replace('bg-', 'text-')}`}>
                  {stat.icon}
                </div>
              </div>
            </div>
            <div className="mt-3">
              <p className="text-sm text-macos-secondary dark:text-macos-dark-secondary">
                {stat.title}
              </p>
              <p className="text-2xl font-semibold text-macos-primary dark:text-macos-dark-primary mt-1">
                {stat.value}
              </p>
              <p className="text-xs text-macos-tertiary dark:text-macos-dark-tertiary">
                {stat.subtitle}
              </p>
            </div>
            <div className="mt-3 h-1.5 bg-macos-sidebar dark:bg-macos-dark-sidebar rounded-full overflow-hidden">
              <div className={`h-full ${stat.color} rounded-full`} style={{ width: '25%' }} />
            </div>
          </motion.div>
        ))}
      </div>

      {/* System Info & Processes */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* System Info */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.4 }}
          className="macos-card p-5"
        >
          <h2 className="text-base font-semibold text-macos-primary dark:text-macos-dark-primary mb-4">
            System Information
          </h2>
          <div className="space-y-3">
            <div className="flex justify-between py-2 border-b border-macos-quaternary/20">
              <span className="text-sm text-macos-secondary dark:text-macos-dark-secondary">Mac Model</span>
              <span className="text-sm font-medium text-macos-primary dark:text-macos-dark-primary">
                MacBook Pro 16"
              </span>
            </div>
            <div className="flex justify-between py-2 border-b border-macos-quaternary/20">
              <span className="text-sm text-macos-secondary dark:text-macos-dark-secondary">Chip</span>
              <span className="text-sm font-medium text-macos-primary dark:text-macos-dark-primary">
                Apple M3 Pro
              </span>
            </div>
            <div className="flex justify-between py-2 border-b border-macos-quaternary/20">
              <span className="text-sm text-macos-secondary dark:text-macos-dark-secondary">macOS</span>
              <span className="text-sm font-medium text-macos-primary dark:text-macos-dark-primary">
                15.2 (Sequoia)
              </span>
            </div>
            <div className="flex justify-between py-2">
              <span className="text-sm text-macos-secondary dark:text-macos-dark-secondary">Uptime</span>
              <span className="text-sm font-medium text-macos-primary dark:text-macos-dark-primary flex items-center gap-1">
                <Clock className="w-3.5 h-3.5" />
                5 days, 12:34
              </span>
            </div>
          </div>
        </motion.div>

        {/* Updates */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.5 }}
          className="macos-card p-5"
        >
          <h2 className="text-base font-semibold text-macos-primary dark:text-macos-dark-primary mb-4">
            {t('dashboard.updatesAvailable')}
          </h2>
          <div className="text-center py-6">
            <CheckCircle2 className="w-12 h-12 text-macos-accent-green mx-auto mb-3" />
            <p className="text-macos-primary dark:text-macos-dark-primary font-medium">
              {t('dashboard.noUpdates')}
            </p>
            <p className="text-sm text-macos-secondary dark:text-macos-dark-secondary mt-1">
              Last checked: 2 hours ago
            </p>
            <button className="macos-button-secondary mt-4 text-sm">
              <RefreshCw className="w-4 h-4 mr-2" />
              Check for Updates
            </button>
          </div>
        </motion.div>
      </div>

      {/* Top Processes */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.6 }}
        className="macos-card p-5"
      >
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-base font-semibold text-macos-primary dark:text-macos-dark-primary">
            {t('dashboard.processes')}
          </h2>
          <button className="macos-button-ghost text-sm">
            View All
          </button>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="text-left text-xs font-medium text-macos-secondary dark:text-macos-dark-secondary border-b border-macos-quaternary/20">
                <th className="pb-3">Application</th>
                <th className="pb-3">CPU</th>
                <th className="pb-3">Memory</th>
              </tr>
            </thead>
            <tbody className="text-sm">
              {processes.map((process) => (
                <tr 
                  key={process.name}
                  className="border-b border-macos-quaternary/10 last:border-0 hover:bg-macos-sidebar/30 transition-colors"
                >
                  <td className="py-3">
                    <div className="flex items-center gap-3">
                      <span className="text-xl">{process.icon}</span>
                      <span className="font-medium text-macos-primary dark:text-macos-dark-primary">
                        {process.name}
                      </span>
                    </div>
                  </td>
                  <td className="py-3 text-macos-secondary dark:text-macos-dark-secondary">
                    {process.cpu}
                  </td>
                  <td className="py-3 text-macos-secondary dark:text-macos-dark-secondary">
                    {process.memory}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </motion.div>
    </motion.div>
  )
}

export default DashboardPage
