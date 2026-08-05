import React from 'react'
import { motion } from 'framer-motion'
import { Apple } from 'lucide-react'

const LoadingScreen: React.FC = () => {
  return (
    <div className="min-h-screen bg-macos-window dark:bg-macos-dark-window flex items-center justify-center">
      <motion.div
        initial={{ opacity: 0, scale: 0.9 }}
        animate={{ opacity: 1, scale: 1 }}
        className="flex flex-col items-center"
      >
        <motion.div
          animate={{ rotate: 360 }}
          transition={{ duration: 2, repeat: Infinity, ease: 'linear' }}
          className="w-16 h-16 bg-macos-accent rounded-2xl flex items-center justify-center mb-4"
        >
          <Apple className="w-8 h-8 text-white" />
        </motion.div>
        <motion.div
          initial={{ width: 0 }}
          animate={{ width: 100 }}
          transition={{ duration: 1.5, repeat: Infinity }}
          className="h-1 bg-macos-accent rounded-full"
        />
        <p className="mt-4 text-macos-secondary dark:text-macos-dark-secondary">
          Loading...
        </p>
      </motion.div>
    </div>
  )
}

export default LoadingScreen
