import React from 'react';
import { Link, useLocation } from 'react-router-dom';
import { motion } from 'framer-motion';
import {
  HomeIcon,
  ArrowUpTrayIcon,
  ComputerDesktopIcon,
  Cog6ToothIcon,
  ChevronLeftIcon,
  ChevronRightIcon,
  SunIcon,
  MoonIcon
} from '@heroicons/react/24/outline';
import { useStore } from '../store/store';

const Sidebar = () => {
  const location = useLocation();
  const { sidebarCollapsed, toggleSidebar, theme, setTheme } = useStore();

  const navigation = [
    { name: 'Home', href: '/', icon: HomeIcon },
    { name: 'Transfers', href: '/transfers', icon: ArrowUpTrayIcon },
    { name: 'Devices', href: '/devices', icon: ComputerDesktopIcon },
    { name: 'Settings', href: '/settings', icon: Cog6ToothIcon },
  ];

  const isActive = (href) => location.pathname === href;

  return (
    <motion.div
      className={`sidebar ${sidebarCollapsed ? 'collapsed' : ''}`}
      initial={{ width: 256 }}
      animate={{ width: sidebarCollapsed ? 64 : 256 }}
      transition={{ duration: 0.3 }}
    >
      <div className="flex flex-col h-full">
        {/* Header */}
        <div className="flex items-center justify-between p-6 border-b border-gray-200 dark:border-gray-700 bg-gradient-to-r from-indigo-600 to-purple-600">
          {!sidebarCollapsed && (
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="flex items-center space-x-3"
            >
              <div className="w-10 h-10 bg-white bg-opacity-20 rounded-xl flex items-center justify-center shadow-md">
                <span className="text-white font-bold text-2xl tracking-tight">S</span>
              </div>
              <span className="text-2xl font-extrabold text-white tracking-wide drop-shadow-lg">
                SwiftShare
              </span>
            </motion.div>
          )}
          <button
            onClick={toggleSidebar}
            className="p-2 rounded-lg hover:bg-white/10 transition-colors"
          >
            {sidebarCollapsed ? (
              <ChevronRightIcon className="w-6 h-6 text-white" />
            ) : (
              <ChevronLeftIcon className="w-6 h-6 text-white" />
            )}
          </button>
        </div>

        {/* Navigation */}
        <nav className="flex-1 px-3 py-6 space-y-2 bg-white dark:bg-gray-800">
          {navigation.map((item) => (
            <Link
              key={item.name}
              to={item.href}
              className={`group flex items-center px-4 py-3 text-base font-medium rounded-lg transition-colors ${
                isActive(item.href)
                  ? 'bg-indigo-100 text-indigo-700 dark:bg-indigo-900 dark:text-indigo-300 shadow'
                  : 'text-gray-700 hover:bg-gray-100 dark:text-gray-300 dark:hover:bg-gray-700'
              }`}
            >
              <item.icon
                className={`mr-4 h-6 w-6 ${
                  isActive(item.href)
                    ? 'text-indigo-700 dark:text-indigo-300'
                    : 'text-gray-400 group-hover:text-indigo-600 dark:text-gray-400 dark:group-hover:text-indigo-300'
                }`}
              />
              {!sidebarCollapsed && (
                <motion.span
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  exit={{ opacity: 0 }}
                >
                  {item.name}
                </motion.span>
              )}
            </Link>
          ))}
        </nav>

        {/* Divider */}
        <div className="border-t border-gray-200 dark:border-gray-700 my-2" />

        {/* Footer */}
        <div className="p-6">
          {!sidebarCollapsed && (
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="space-y-4"
            >
              {/* Theme Toggle */}
              <div className="flex items-center justify-between">
                <span className="text-sm font-medium text-gray-700 dark:text-gray-300">Theme</span>
                <button
                  onClick={() => setTheme(theme === 'light' ? 'dark' : 'light')}
                  className="flex items-center space-x-2 px-3 py-2 rounded-lg bg-gray-100 dark:bg-gray-700 hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors"
                >
                  {theme === 'light' ? (
                    <SunIcon className="w-5 h-5 text-yellow-400" />
                  ) : (
                    <MoonIcon className="w-5 h-5 text-indigo-300" />
                  )}
                  <span className="text-xs font-semibold text-gray-700 dark:text-gray-200">
                    {theme === 'light' ? 'Light' : 'Dark'}
                  </span>
                </button>
              </div>

              {/* Version */}
              <div className="text-xs text-gray-400 dark:text-gray-500 text-right">
                v1.0.0
              </div>
            </motion.div>
          )}
        </div>
      </div>
    </motion.div>
  );
};

export default Sidebar; 