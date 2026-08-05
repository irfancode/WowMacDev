import React, { useState } from 'react'
import { useTranslation } from 'react-i18next'
import { useNavigate } from 'react-router-dom'
import { motion } from 'framer-motion'
import { Apple, Lock, User } from 'lucide-react'
import { useAuthStore } from '../../store/authStore'
import toast from 'react-hot-toast'

const LoginPage: React.FC = () => {
  const { t } = useTranslation()
  const navigate = useNavigate()
  const { login } = useAuthStore()
  
  const [username, setUsername] = useState('')
  const [password, setPassword] = useState('')
  const [isLoading, setIsLoading] = useState(false)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setIsLoading(true)

    try {
      await login(username, password)
      navigate('/dashboard')
      toast.success('Welcome to MacAdmin')
    } catch (err) {
      toast.error(t('auth.loginError'))
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="macos-card p-8 max-w-sm mx-auto"
    >
      {/* Logo */}
      <div className="flex flex-col items-center mb-8">
        <div className="w-20 h-20 bg-macos-accent rounded-3xl flex items-center justify-center mb-4 shadow-lg">
          <Apple className="w-10 h-10 text-white" />
        </div>
        <h1 className="text-2xl font-semibold text-macos-primary dark:text-macos-dark-primary">
          {t('app.name')}
        </h1>
        <p className="text-macos-secondary dark:text-macos-dark-secondary mt-1 text-center">
          {t('auth.welcomeSubtitle')}
        </p>
      </div>

      {/* Login Form */}
      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <label className="block text-sm font-medium text-macos-secondary dark:text-macos-dark-secondary mb-1.5">
            {t('auth.username')}
          </label>
          <div className="relative">
            <User className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-macos-tertiary" />
            <input
              type="text"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              className="macos-input pl-10"
              placeholder="admin"
              required
              autoFocus
            />
          </div>
        </div>

        <div>
          <label className="block text-sm font-medium text-macos-secondary dark:text-macos-dark-secondary mb-1.5">
            {t('auth.password')}
          </label>
          <div className="relative">
            <Lock className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-macos-tertiary" />
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="macos-input pl-10"
              placeholder="••••••••"
              required
            />
          </div>
        </div>

        <button
          type="submit"
          disabled={isLoading}
          className="macos-button w-full py-2.5 mt-6"
        >
          {isLoading ? (
            <div className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin" />
          ) : (
            t('auth.loginButton')
          )}
        </button>
      </form>

      <p className="text-center text-xs text-macos-tertiary dark:text-macos-dark-tertiary mt-6">
        Use your macOS user credentials
      </p>
    </motion.div>
  )
}

export default LoginPage
