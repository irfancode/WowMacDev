import React, { useState } from 'react'
import { useTranslation } from 'react-i18next'
import { motion, AnimatePresence } from 'framer-motion'
import { 
  Package, 
  Terminal, 
  Download, 
  Check, 
  AlertCircle,
  ChevronDown,
  ChevronUp,
  RefreshCw,
  Trash2,
  Box,
  Search,
  Code
} from 'lucide-react'
import toast from 'react-hot-toast'
import {
  useCheckCLITools,
  useInstallCLITools,
  useCheckBrew,
  useInstallBrew,
  useBrewPackages,
  useBrewCasks,
  useInstallPackage,
  useInstallCask,
  useInstalledPackages,
  useUpdateBrew,
  useCleanupBrew,
} from '../../hooks/useBrew'

interface PackageItem {
  name: string
  description: string
  installed: boolean
}

interface CategoryData {
  name: string
  description: string
  packages: PackageItem[]
}

const BrewManagerPage: React.FC = () => {
  const { t } = useTranslation()
  const [activeTab, setActiveTab] = useState<'packages' | 'casks'>('packages')
  const [expandedCategories, setExpandedCategories] = useState<string[]>(['essentials'])
  const [searchQuery, setSearchQuery] = useState('')

  const { data: cliToolsData, isLoading: cliLoading } = useCheckCLITools()
  const { data: brewData, isLoading: brewLoading } = useCheckBrew()
  const { data: packagesData, isLoading: packagesLoading } = useBrewPackages()
  const { data: casksData, isLoading: casksLoading } = useBrewCasks()
  const { data: installedData, isLoading: installedLoading } = useInstalledPackages()

  const installCLITools = useInstallCLITools()
  const installBrew = useInstallBrew()
  const installPackage = useInstallPackage()
  const installCask = useInstallCask()
  const updateBrew = useUpdateBrew()
  const cleanupBrew = useCleanupBrew()

  const toggleCategory = (category: string) => {
    setExpandedCategories(prev => 
      prev.includes(category) 
        ? prev.filter(c => c !== category)
        : [...prev, category]
    )
  }

  const handleInstallCLITools = async () => {
    try {
      const result = await installCLITools.mutateAsync()
      toast.success(result.message)
    } catch (error) {
      toast.error('Failed to install Command Line Tools')
    }
  }

  const handleInstallBrew = async () => {
    try {
      const result = await installBrew.mutateAsync()
      toast.success(result.message)
      if (result.command) {
        navigator.clipboard.writeText(result.command)
        toast.info('Installation command copied to clipboard')
      }
    } catch (error) {
      toast.error('Failed to initiate Homebrew installation')
    }
  }

  const handleInstallPackage = async (packageName: string) => {
    try {
      const result = await installPackage.mutateAsync(packageName)
      if (result.success) {
        toast.success(result.message)
      } else {
        toast.error(result.message)
      }
    } catch (error) {
      toast.error(`Failed to install ${packageName}`)
    }
  }

  const handleInstallCask = async (caskName: string) => {
    try {
      const result = await installCask.mutateAsync(caskName)
      if (result.success) {
        toast.success(result.message)
      } else {
        toast.error(result.message)
      }
    } catch (error) {
      toast.error(`Failed to install ${caskName}`)
    }
  }

  const handleUpdateBrew = async () => {
    try {
      const result = await updateBrew.mutateAsync()
      toast.success(result.message)
    } catch (error) {
      toast.error('Failed to update Homebrew')
    }
  }

  const handleCleanupBrew = async () => {
    try {
      const result = await cleanupBrew.mutateAsync()
      toast.success(result.message)
    } catch (error) {
      toast.error('Failed to cleanup Homebrew')
    }
  }

  const filterPackages = (packages: PackageItem[]) => {
    if (!searchQuery) return packages
    return packages.filter(pkg => 
      pkg.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      pkg.description.toLowerCase().includes(searchQuery.toLowerCase())
    )
  }

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      className="space-y-6"
    >
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="p-2.5 bg-macos-accent-orange/10 rounded-xl">
            <Package className="w-6 h-6 text-macos-accent-orange" />
          </div>
          <div>
            <h1 className="text-2xl font-semibold text-macos-primary dark:text-macos-dark-primary">
              Homebrew Manager
            </h1>
            <p className="text-macos-secondary dark:text-macos-dark-secondary">
              Manage packages and applications
            </p>
          </div>
        </div>

        <div className="flex items-center gap-2">
          <button
            onClick={handleUpdateBrew}
            disabled={updateBrew.isPending || !brewData?.installed}
            className="macos-button-secondary text-sm flex items-center gap-2"
          >
            <RefreshCw className={`w-4 h-4 ${updateBrew.isPending ? 'animate-spin' : ''}`} />
            Update
          </button>
          <button
            onClick={handleCleanupBrew}
            disabled={cleanupBrew.isPending || !brewData?.installed}
            className="macos-button-secondary text-sm flex items-center gap-2"
          >
            <Trash2 className="w-4 h-4" />
            Cleanup
          </button>
        </div>
      </div>

      {/* Prerequisites Check */}
      <motion.div
        initial={{ opacity: 0, y: 10 }}
        animate={{ opacity: 1, y: 0 }}
        className="macos-card p-5"
      >
        <h2 className="text-base font-semibold text-macos-primary dark:text-macos-dark-primary mb-4">
          Prerequisites
        </h2>
        <div className="space-y-4">
          {/* CLI Tools */}
          <div className="flex items-center justify-between p-4 bg-macos-sidebar/50 dark:bg-macos-dark-sidebar/50 rounded-lg">
            <div className="flex items-center gap-3">
              <div className={`p-2 rounded-lg ${cliToolsData?.installed ? 'bg-macos-accent-green/10' : 'bg-macos-accent-orange/10'}`}>
                <Terminal className={`w-5 h-5 ${cliToolsData?.installed ? 'text-macos-accent-green' : 'text-macos-accent-orange'}`} />
              </div>
              <div>
                <p className="font-medium text-macos-primary dark:text-macos-dark-primary">
                  Command Line Tools
                </p>
                <p className="text-sm text-macos-secondary dark:text-macos-dark-secondary">
                  {cliToolsData?.installed ? 'Installed' : 'Not installed'}
                </p>
              </div>
            </div>
            {!cliToolsData?.installed && (
              <button
                onClick={handleInstallCLITools}
                disabled={installCLITools.isPending}
                className="macos-button text-sm flex items-center gap-2"
              >
                {installCLITools.isPending ? (
                  <RefreshCw className="w-4 h-4 animate-spin" />
                ) : (
                  <Download className="w-4 h-4" />
                )}
                Install
              </button>
            )}
          </div>

          {/* Homebrew */}
          <div className="flex items-center justify-between p-4 bg-macos-sidebar/50 dark:bg-macos-dark-sidebar/50 rounded-lg">
            <div className="flex items-center gap-3">
              <div className={`p-2 rounded-lg ${brewData?.installed ? 'bg-macos-accent-green/10' : 'bg-macos-accent-orange/10'}`}>
                <Box className={`w-5 h-5 ${brewData?.installed ? 'text-macos-accent-green' : 'text-macos-accent-orange'}`} />
              </div>
              <div>
                <p className="font-medium text-macos-primary dark:text-macos-dark-primary">
                  Homebrew
                </p>
                <p className="text-sm text-macos-secondary dark:text-macos-dark-secondary">
                  {brewData?.installed 
                    ? `Installed (${brewData.info?.version || 'Unknown'})` 
                    : 'Not installed'}
                </p>
              </div>
            </div>
            {!brewData?.installed && (
              <button
                onClick={handleInstallBrew}
                disabled={installBrew.isPending}
                className="macos-button text-sm flex items-center gap-2"
              >
                {installBrew.isPending ? (
                  <RefreshCw className="w-4 h-4 animate-spin" />
                ) : (
                  <Download className="w-4 h-4" />
                )}
                Install
              </button>
            )}
          </div>
        </div>
      </motion.div>

      {/* Installation Stats */}
      {brewData?.installed && installedData && (
        <motion.div
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          className="grid grid-cols-2 gap-4"
        >
          <div className="macos-card p-4">
            <p className="text-sm text-macos-secondary dark:text-macos-dark-secondary">Installed Formulae</p>
            <p className="text-2xl font-semibold text-macos-primary dark:text-macos-dark-primary">
              {installedData.total_formulae}
            </p>
          </div>
          <div className="macos-card p-4">
            <p className="text-sm text-macos-secondary dark:text-macos-dark-secondary">Installed Casks</p>
            <p className="text-2xl font-semibold text-macos-primary dark:text-macos-dark-primary">
              {installedData.total_casks}
            </p>
          </div>
        </motion.div>
      )}

      {/* Tabs */}
      {brewData?.installed && (
        <>
          <div className="flex items-center gap-2 border-b border-macos-quaternary/20">
            <button
              onClick={() => setActiveTab('packages')}
              className={`px-4 py-2 font-medium text-sm transition-colors ${
                activeTab === 'packages'
                  ? 'text-macos-accent border-b-2 border-macos-accent'
                  : 'text-macos-secondary hover:text-macos-primary'
              }`}
            >
              CLI Packages
            </button>
            <button
              onClick={() => setActiveTab('casks')}
              className={`px-4 py-2 font-medium text-sm transition-colors ${
                activeTab === 'casks'
                  ? 'text-macos-accent border-b-2 border-macos-accent'
                  : 'text-macos-secondary hover:text-macos-primary'
              }`}
            >
              GUI Applications
            </button>
          </div>

          {/* Search */}
          <div className="relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-macos-tertiary" />
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder={`Search ${activeTab}...`}
              className="macos-input pl-10 w-full"
            />
          </div>

          {/* Packages List */}
          {activeTab === 'packages' && packagesData && (
            <div className="space-y-4">
              {Object.entries(packagesData as Record<string, CategoryData>).map(([key, category]) => {
                const filteredPackages = filterPackages(category.packages)
                if (searchQuery && filteredPackages.length === 0) return null

                return (
                  <motion.div
                    key={key}
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    className="macos-card overflow-hidden"
                  >
                    <button
                      onClick={() => toggleCategory(key)}
                      className="w-full flex items-center justify-between p-4 hover:bg-macos-sidebar/30 transition-colors"
                    >
                      <div className="text-left">
                        <h3 className="font-semibold text-macos-primary dark:text-macos-dark-primary">
                          {category.name}
                        </h3>
                        <p className="text-sm text-macos-secondary dark:text-macos-dark-secondary">
                          {category.description}
                        </p>
                      </div>
                      {expandedCategories.includes(key) ? (
                        <ChevronUp className="w-5 h-5 text-macos-tertiary" />
                      ) : (
                        <ChevronDown className="w-5 h-5 text-macos-tertiary" />
                      )}
                    </button>
                    
                    <AnimatePresence>
                      {expandedCategories.includes(key) && (
                        <motion.div
                          initial={{ height: 0 }}
                          animate={{ height: 'auto' }}
                          exit={{ height: 0 }}
                          className="overflow-hidden"
                        >
                          <div className="border-t border-macos-quaternary/20">
                            {filteredPackages.map((pkg) => (
                              <div
                                key={pkg.name}
                                className="flex items-center justify-between p-4 hover:bg-macos-sidebar/30 transition-colors border-b border-macos-quaternary/10 last:border-0"
                              >
                                <div>
                                  <p className="font-medium text-macos-primary dark:text-macos-dark-primary">
                                    {pkg.name}
                                  </p>
                                  <p className="text-sm text-macos-secondary dark:text-macos-dark-secondary">
                                    {pkg.description}
                                  </p>
                                </div>
                                <button
                                  onClick={() => handleInstallPackage(pkg.name)}
                                  disabled={pkg.installed || installPackage.isPending}
                                  className={`flex items-center gap-2 px-3 py-1.5 rounded-lg text-sm font-medium transition-colors ${
                                    pkg.installed
                                      ? 'bg-macos-accent-green/10 text-macos-accent-green cursor-default'
                                      : 'bg-macos-accent text-white hover:bg-macos-accent/90'
                                  }`}
                                >
                                  {pkg.installed ? (
                                    <>
                                      <Check className="w-4 h-4" />
                                      Installed
                                    </>
                                  ) : installPackage.isPending ? (
                                    <RefreshCw className="w-4 h-4 animate-spin" />
                                  ) : (
                                    <>
                                      <Download className="w-4 h-4" />
                                      Install
                                    </>
                                  )}
                                </button>
                              </div>
                            ))}
                          </div>
                        </motion.div>
                      )}
                    </AnimatePresence>
                  </motion.div>
                )
              })}
            </div>
          )}

          {/* Casks List */}
          {activeTab === 'casks' && casksData && (
            <div className="space-y-4">
              {Object.entries(casksData as Record<string, CategoryData>).map(([key, category]) => {
                const filteredCasks = filterPackages(category.packages)
                if (searchQuery && filteredCasks.length === 0) return null

                return (
                  <motion.div
                    key={key}
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    className="macos-card overflow-hidden"
                  >
                    <button
                      onClick={() => toggleCategory(key)}
                      className="w-full flex items-center justify-between p-4 hover:bg-macos-sidebar/30 transition-colors"
                    >
                      <div className="text-left">
                        <h3 className="font-semibold text-macos-primary dark:text-macos-dark-primary">
                          {category.name}
                        </h3>
                        <p className="text-sm text-macos-secondary dark:text-macos-dark-secondary">
                          {category.description}
                        </p>
                      </div>
                      {expandedCategories.includes(key) ? (
                        <ChevronUp className="w-5 h-5 text-macos-tertiary" />
                      ) : (
                        <ChevronDown className="w-5 h-5 text-macos-tertiary" />
                      )}
                    </button>
                    
                    <AnimatePresence>
                      {expandedCategories.includes(key) && (
                        <motion.div
                          initial={{ height: 0 }}
                          animate={{ height: 'auto' }}
                          exit={{ height: 0 }}
                          className="overflow-hidden"
                        >
                          <div className="border-t border-macos-quaternary/20">
                            {filteredCasks.map((cask) => (
                              <div
                                key={cask.name}
                                className="flex items-center justify-between p-4 hover:bg-macos-sidebar/30 transition-colors border-b border-macos-quaternary/10 last:border-0"
                              >
                                <div>
                                  <p className="font-medium text-macos-primary dark:text-macos-dark-primary">
                                    {cask.name}
                                  </p>
                                  <p className="text-sm text-macos-secondary dark:text-macos-dark-secondary">
                                    {cask.description}
                                  </p>
                                </div>
                                <button
                                  onClick={() => handleInstallCask(cask.name)}
                                  disabled={cask.installed || installCask.isPending}
                                  className={`flex items-center gap-2 px-3 py-1.5 rounded-lg text-sm font-medium transition-colors ${
                                    cask.installed
                                      ? 'bg-macos-accent-green/10 text-macos-accent-green cursor-default'
                                      : 'bg-macos-accent text-white hover:bg-macos-accent/90'
                                  }`}
                                >
                                  {cask.installed ? (
                                    <>
                                      <Check className="w-4 h-4" />
                                      Installed
                                    </>
                                  ) : installCask.isPending ? (
                                    <RefreshCw className="w-4 h-4 animate-spin" />
                                  ) : (
                                    <>
                                      <Download className="w-4 h-4" />
                                      Install
                                    </>
                                  )}
                                </button>
                              </div>
                            ))}
                          </div>
                        </motion.div>
                      )}
                    </AnimatePresence>
                  </motion.div>
                )
              })}
            </div>
          )}
        </>
      )}

      {!brewData?.installed && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          className="macos-card p-8 text-center"
        >
          <AlertCircle className="w-12 h-12 text-macos-accent-orange mx-auto mb-4" />
          <h3 className="text-lg font-semibold text-macos-primary dark:text-macos-dark-primary mb-2">
            Homebrew Required
          </h3>
          <p className="text-macos-secondary dark:text-macos-dark-secondary mb-4">
            Please install Homebrew to manage packages and applications.
          </p>
          <button
            onClick={handleInstallBrew}
            className="macos-button flex items-center gap-2 mx-auto"
          >
            <Download className="w-4 h-4" />
            Install Homebrew
          </button>
        </motion.div>
      )}
    </motion.div>
  )
}

export default BrewManagerPage
