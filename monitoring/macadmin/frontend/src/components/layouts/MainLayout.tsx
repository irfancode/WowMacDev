import React from 'react'
import { Outlet } from 'react-router-dom'
import Sidebar from '../navigation/Sidebar'
import Header from '../navigation/Header'

const MainLayout: React.FC = () => {
  return (
    <div className="min-h-screen flex bg-macos-window dark:bg-macos-dark-window">
      <Sidebar />
      <div className="flex-1 flex flex-col min-w-0">
        <Header />
        <main className="flex-1 p-6 overflow-auto">
          <div className="max-w-6xl mx-auto">
            <Outlet />
          </div>
        </main>
      </div>
    </div>
  )
}

export default MainLayout
