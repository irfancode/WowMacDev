import React from 'react'
import { useTranslation } from 'react-i18next'
import { motion } from 'framer-motion'
import { Settings as SettingsIcon, Moon, Sun, Monitor, Palette } from 'lucide-react'
import { useThemeStore } from '../../store/themeStore'

const SettingsPage: React.FC = () => {
  const { t } = useTranslation()
  const { theme, setTheme, accentColor, setAccentColor } = useThemeStore()

  const accentColors = [
    { name: 'blue', class: 'bg-macos-accent-blue', label: 'Blue' },
    { name: 'purple', class: 'bg-macos-accent-purple', label: 'Purple' },
    { name: 'pink', class: 'bg-macos-accent-pink', label: 'Pink' },
    { name: 'red', class: 'bg-macos-accent-red', label: 'Red' },
    { name: 'orange', class: 'bg-macos-accent-orange', label: 'Orange' },
    { name: 'yellow', class: 'bg-macos-accent-yellow', label: 'Yellow' },
    { name: 'green', class: 'bg-macos-accent-green', label: 'Green' },
    { name: 'teal', class: 'bg-macos-accent-teal', label: 'Teal' },
  ]

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      className="space-y-6"
    >
      {/* Header */}
      <div className="flex items-center gap-3">
        <div className="p-2.5 bg-macos-accent/10 rounded-xl">
          <SettingsIcon className="w-6 h-6 text-macos-accent" />
        </div>
        <div>
          <h1 className="text-2xl font-semibold text-macos-primary dark:text-macos-dark-primary">
            {t('settings.title')}
          </h1>
          <p className="text-macos-secondary dark:text-macos-dark-secondary">
            Customize MacAdmin
          </p>
        </div>
      </div>

      {/* Settings Sections */}
      <div className="space-y-4">
        {/* Appearance */}
        <motion.div
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1 }}
          className="macos-card p-5"
        >
          <div className="flex items-center gap-3 mb-4">
            <div className="p-2 bg-macos-accent-purple/10 rounded-lg">
              <Palette className="w-5 h-5 text-macos-accent-purple" />
            </div>
            <h2 className="text-base font-semibold text-macos-primary dark:text-macos-dark-primary">
              {t('settings.appearance')}
            </h2>
          </div>

          <div className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-macos-secondary dark:text-macos-dark-secondary mb-2">
                {t('settings.theme.title')}
              </label>
              <div className="flex gap-2">
                {(['light', 'dark', 'auto'] as const).map((t) => (
                  <button
                    key={t}
                    onClick={() => setTheme(t)}
                    className={`flex items-center gap-2 px-4 py-2 rounded-lg font-medium text-sm transition-all ${
                      theme === t
                        ? 'bg-macos-accent text-white'
                        : 'bg-macos-sidebar dark:bg-macos-dark-sidebar text-macos-primary dark:text-macos-dark-primary hover:bg-macos-quaternary/20'
                    }`}
                  >
                    {t === 'light' && <Sun className="w-4 h-4" />}
                    {t === 'dark' && <Moon className="w-4 h-4" />}
                    {t === 'auto' && <Monitor className="w-4 h-4" />}
                    {t.charAt(0).toUpperCase() + t.slice(1)}
                  </button>
                ))}
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-macos-secondary dark:text-macos-dark-secondary mb-2">
                Accent Color
              </label>
              <div className="flex gap-2 flex-wrap">
                {accentColors.map((color) => (
                  <button
                    key={color.name}
                    onClick={() => setAccentColor(color.name)}
                    className={`w-8 h-8 rounded-full ${color.class} transition-transform hover:scale-110 ${
                      accentColor === color.name ? 'ring-2 ring-offset-2 ring-macos-primary' : ''
                    }`}
                    title={color.label}
                  />
                ))}
              </div>
            </div>
          </div>
        </motion.div>

        {/* General Settings */}
        <motion.div
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2 }}
          className="macos-card p-5"
        >
          <h2 className="text-base font-semibold text-macos-primary dark:text-macos-dark-primary mb-4">
            {t('settings.general')}
          </h2>
          <div className="space-y-3">
            {[
              { label: 'Launch at login', checked: true },
              { label: 'Show in menu bar', checked: true },
              { label: 'Check for updates automatically', checked: true },
            ].map((item) => (
              <label key={item.label} className="flex items-center justify-between p-3 bg-macos-sidebar/50 dark:bg-macos-dark-sidebar/50 rounded-lg cursor-pointer">
                <span className="text-sm text-macos-primary dark:text-macos-dark-primary">{item.label}</span>
                <input
                  type="checkbox"
                  defaultChecked={item.checked}
                  className="w-5 h-5 rounded border-macos-quaternary text-macos-accent focus:ring-macos-accent"
                />
              </label>
            ))}
          </div>
        </motion.div>
      </div>
    </motion.div>
  )
}

export default SettingsPage
