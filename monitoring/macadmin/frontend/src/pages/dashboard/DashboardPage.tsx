import React from 'react'
import { useTranslation } from 'react-i18next'
import { motion } from 'framer-motion'
import {
  Cpu,
  HardDrive,
  Wifi,
  Activity,
  CheckCircle2,
  Server,
  Clock,
  RefreshCw,
  MemoryStick,
} from 'lucide-react'
import {
  useSystemMetrics,
  useSystemInfo,
  useTopProcesses,
  useAvailableUpdates,
  formatBytes,
  formatSpeed,
} from '../../hooks/useSystem'

const DashboardPage: React.FC = () => {
  const { t } = useTranslation()

  const { data: metrics } = useSystemMetrics()
  const { data: info } = useSystemInfo()
  const { data: processes, isLoading: processesLoading } = useTopProcesses()
  const { data: updates, refetch: refetchUpdates, isFetching: updatesFetching } = useAvailableUpdates()

  const cpu = metrics?.cpu || { percent: 0, count: 0 }
  const memory = metrics?.memory || { total: 1, used: 0, percent: 0 }
  const disk = metrics?.disk || { total: 1, used: 0, percent: 0 }
  const network = metrics?.network || { bytes_sent: 0, bytes_recv: 0 }
  const downloadSpeed = Number((network.bytes_recv / 5 || 0).toFixed(1))

  const stats = [
    {
      title: t('dashboard.cpu'),
      value: `${cpu.percent}%`,
      subtitle: `${cpu.count} ${t('dashboard.cores')}`,
      icon: <Cpu className="w-5 h-5" />,
      color: 'bg-macos-accent-blue',
      percent: cpu.percent,
    },
    {
      title: t('dashboard.memory'),
      value: formatBytes(memory.used),
      subtitle: t('dashboard.memoryDetail', { total: formatBytes(memory.total) }),
      icon: <MemoryStick className="w-5 h-5" />,
      color: 'bg-macos-accent-green',
      percent: memory.percent,
    },
    {
      title: t('dashboard.disk'),
      value: formatBytes(disk.used),
      subtitle: t('dashboard.memoryDetail', { total: formatBytes(disk.total) }),
      icon: <HardDrive className="w-5 h-5" />,
      color: 'bg-macos-accent-orange',
      percent: disk.percent,
    },
    {
      title: t('dashboard.network'),
      value: formatSpeed(downloadSpeed),
      subtitle: t('dashboard.download'),
      icon: <Wifi className="w-5 h-5" />,
      color: 'bg-macos-accent-purple',
      percent: Math.min(downloadSpeed ? (downloadSpeed / 125000) * 100 : 0, 100),
    },
  ]

  const topProcesses = processes?.length
    ? [...processes].sort((a: any, b: any) => (b.cpu_percent || 0) - (a.cpu_percent || 0)).slice(0, 5)
    : []

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
              <div
                className={`h-full ${stat.color} rounded-full transition-all duration-500`}
                style={{ width: `${Math.min(stat.percent, 100)}%` }}
              />
            </div>
          </motion.div>
        ))}
      </div>

      {/* System Info & Updates */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* System Info */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.4 }}
          className="macos-card p-5"
        >
          <h2 className="text-base font-semibold text-macos-primary dark:text-macos-dark-primary mb-4">
            {t('dashboard.systemInfo')}
          </h2>
          <div className="space-y-3">
            <div className="flex justify-between py-2 border-b border-macos-quaternary/20">
              <span className="text-sm text-macos-secondary dark:text-macos-dark-secondary">Mac Model</span>
              <span className="text-sm font-medium text-macos-primary dark:text-macos-dark-primary">
                {info?.model || '—'}
              </span>
            </div>
            <div className="flex justify-between py-2 border-b border-macos-quaternary/20">
              <span className="text-sm text-macos-secondary dark:text-macos-dark-secondary">Chip</span>
              <span className="text-sm font-medium text-macos-primary dark:text-macos-dark-primary">
                {info?.chip || '—'}
              </span>
            </div>
            <div className="flex justify-between py-2 border-b border-macos-quaternary/20">
              <span className="text-sm text-macos-secondary dark:text-macos-dark-secondary">macOS</span>
              <span className="text-sm font-medium text-macos-primary dark:text-macos-dark-primary">
                {info?.os_version || info?.platform || '—'}
              </span>
            </div>
            <div className="flex justify-between py-2">
              <span className="text-sm text-macos-secondary dark:text-macos-dark-secondary">Uptime</span>
              <span className="text-sm font-medium text-macos-primary dark:text-macos-dark-primary flex items-center gap-1">
                <Clock className="w-3.5 h-3.5" />
                {metrics?.uptime || '—'}
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
              {updates?.available ? `${updates.updates?.length || 0} ${t('dashboard.updatesAvailable').toLowerCase()}` : t('dashboard.upToDate')}
            </p>
            <button
              onClick={() => refetchUpdates()}
              disabled={updatesFetching}
              className="macos-button-secondary mt-4 text-sm inline-flex items-center disabled:opacity-50"
            >
              <RefreshCw className={`w-4 h-4 mr-2 ${updatesFetching ? 'animate-spin' : ''}`} />
              {t('dashboard.checkUpdates')}
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
        </div>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="text-left text-xs font-medium text-macos-secondary dark:text-macos-dark-secondary border-b border-macos-quaternary/20">
                <th className="pb-3">Process</th>
                <th className="pb-3">PID</th>
                <th className="pb-3">CPU</th>
                <th className="pb-3">Memory</th>
              </tr>
            </thead>
            <tbody className="text-sm">
              {processesLoading ? (
                <tr>
                  <td colSpan={4} className="py-6 text-center text-macos-tertiary dark:text-macos-dark-tertiary">
                    Loading processes...
                  </td>
                </tr>
              ) : topProcesses.length === 0 ? (
                <tr>
                  <td colSpan={4} className="py-6 text-center text-macos-tertiary dark:text-macos-dark-tertiary">
                    No process data available
                  </td>
                </tr>
              ) : (
                topProcesses.map((process: any) => (
                  <tr
                    key={process.pid}
                    className="border-b border-macos-quaternary/10 last:border-0 hover:bg-macos-sidebar/30 transition-colors"
                  >
                    <td className="py-3">
                      <div className="flex items-center gap-3">
                        <Server className="w-4 h-4 text-macos-secondary dark:text-macos-dark-secondary" />
                        <span className="font-medium text-macos-primary dark:text-macos-dark-primary">
                          {process.name}
                        </span>
                      </div>
                    </td>
                    <td className="py-3 text-macos-secondary dark:text-macos-dark-secondary">{process.pid}</td>
                    <td className="py-3 text-macos-secondary dark:text-macos-dark-secondary">
                      {process.cpu_percent?.toFixed(1)}%
                    </td>
                    <td className="py-3 text-macos-secondary dark:text-macos-dark-secondary">
                      {process.memory_percent?.toFixed(1)}%
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </motion.div>
    </motion.div>
  )
}

export default DashboardPage