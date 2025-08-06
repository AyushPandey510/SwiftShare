import React, { useState } from 'react';
import { useStore } from '../store/store';
import Tooltip from '../components/Tooltip';

const Settings = ({ showToast }) => {
  const { settings, updateSettings, theme, setTheme } = useStore();
  const [activeTab, setActiveTab] = useState('general');

  const handleSettingChange = (key, value) => {
    updateSettings({ [key]: value });
    showToast(`Setting updated: ${key}`, 'success');
  };

  const handleThemeChange = (newTheme) => {
    setTheme(newTheme);
    showToast(`Theme changed to ${newTheme}`, 'success');
  };

  const tabs = [
    { id: 'general', label: 'General', icon: '⚙️' },
    { id: 'transfer', label: 'Transfer', icon: '📤' },
    { id: 'network', label: 'Network', icon: '🌐' },
    { id: 'about', label: 'About', icon: 'ℹ️' }
  ];

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold text-gray-900 dark:text-white">
          Settings
        </h1>
        <p className="text-gray-600 dark:text-gray-400 mt-1">
          Configure SwiftShare to your preferences
        </p>
      </div>

      {/* Tabs */}
      <div className="border-b border-gray-200 dark:border-gray-700">
        <div className="flex space-x-8">
          {tabs.map(tab => (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id)}
              className={`flex items-center space-x-2 py-4 px-1 border-b-2 font-medium text-sm transition-colors ${
                activeTab === tab.id
                  ? 'border-blue-500 text-blue-600 dark:text-blue-400'
                  : 'border-transparent text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:hover:text-gray-300'
              }`}
            >
              <span className="text-lg">{tab.icon}</span>
              <span>{tab.label}</span>
            </button>
          ))}
        </div>
      </div>

      {/* Tab Content */}
      <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-6">
        {activeTab === 'general' && (
          <div className="space-y-6">
            <div>
              <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">
                General Settings
              </h3>
              
              {/* Theme Selection */}
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    Theme
                  </label>
                  <div className="grid grid-cols-3 gap-3">
                    {[
                      { value: 'light', label: 'Light', icon: '☀️' },
                      { value: 'dark', label: 'Dark', icon: '🌙' },
                      { value: 'system', label: 'System', icon: '🖥️' }
                    ].map(themeOption => (
                      <button
                        key={themeOption.value}
                        onClick={() => handleThemeChange(themeOption.value)}
                        className={`p-4 rounded-lg border-2 transition-all duration-200 ${
                          theme === themeOption.value
                            ? 'border-blue-500 bg-blue-50 dark:bg-blue-900/20'
                            : 'border-gray-200 dark:border-gray-700 hover:border-gray-300 dark:hover:border-gray-600'
                        }`}
                      >
                        <div className="text-2xl mb-2">{themeOption.icon}</div>
                        <div className="text-sm font-medium text-gray-900 dark:text-white">
                          {themeOption.label}
                        </div>
                      </button>
                    ))}
                  </div>
                </div>

                {/* Auto-scan */}
                <div className="flex items-center justify-between">
                  <div>
                    <label className="text-sm font-medium text-gray-700 dark:text-gray-300">
                      Auto-scan for devices
                    </label>
                    <p className="text-xs text-gray-500 dark:text-gray-400">
                      Automatically scan for new devices when the app starts
                    </p>
                  </div>
                  <Tooltip text={settings.autoScan ? 'Disable auto-scan' : 'Enable auto-scan'}>
                    <button
                      onClick={() => handleSettingChange('autoScan', !settings.autoScan)}
                      className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors ${
                        settings.autoScan ? 'bg-blue-600' : 'bg-gray-200 dark:bg-gray-700'
                      }`}
                    >
                      <span
                        className={`inline-block h-4 w-4 transform rounded-full bg-white transition-transform ${
                          settings.autoScan ? 'translate-x-6' : 'translate-x-1'
                        }`}
                      />
                    </button>
                  </Tooltip>
                </div>
              </div>
            </div>
          </div>
        )}

        {activeTab === 'transfer' && (
          <div className="space-y-6">
            <div>
              <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">
                Transfer Settings
              </h3>
              
              <div className="space-y-4">
                {/* Encryption */}
                <div className="flex items-center justify-between">
                  <div>
                    <label className="text-sm font-medium text-gray-700 dark:text-gray-300">
                      Enable encryption
                    </label>
                    <p className="text-xs text-gray-500 dark:text-gray-400">
                      Encrypt files during transfer for enhanced security
                    </p>
                  </div>
                  <Tooltip text={settings.encryption ? 'Disable encryption' : 'Enable encryption'}>
                    <button
                      onClick={() => handleSettingChange('encryption', !settings.encryption)}
                      className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors ${
                        settings.encryption ? 'bg-blue-600' : 'bg-gray-200 dark:bg-gray-700'
                      }`}
                    >
                      <span
                        className={`inline-block h-4 w-4 transform rounded-full bg-white transition-transform ${
                          settings.encryption ? 'translate-x-6' : 'translate-x-1'
                        }`}
                      />
                    </button>
                  </Tooltip>
                </div>

                {/* Compression */}
                <div className="flex items-center justify-between">
                  <div>
                    <label className="text-sm font-medium text-gray-700 dark:text-gray-300">
                      Enable compression
                    </label>
                    <p className="text-xs text-gray-500 dark:text-gray-400">
                      Compress files to reduce transfer time
                    </p>
                  </div>
                  <Tooltip text={settings.compression ? 'Disable compression' : 'Enable compression'}>
                    <button
                      onClick={() => handleSettingChange('compression', !settings.compression)}
                      className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors ${
                        settings.compression ? 'bg-blue-600' : 'bg-gray-200 dark:bg-gray-700'
                      }`}
                    >
                      <span
                        className={`inline-block h-4 w-4 transform rounded-full bg-white transition-transform ${
                          settings.compression ? 'translate-x-6' : 'translate-x-1'
                        }`}
                      />
                    </button>
                  </Tooltip>
                </div>

                {/* Download Path */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    Download Directory
                  </label>
                  <div className="flex items-center space-x-3">
                    <input
                      type="text"
                      value={settings.downloadPath || 'Default'}
                      readOnly
                      className="flex-1 px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-gray-50 dark:bg-gray-700 text-gray-900 dark:text-white text-sm"
                    />
                    <Tooltip text="Change download directory">
                      <button className="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg text-sm font-medium transition-colors">
                        Browse
                      </button>
                    </Tooltip>
                  </div>
                </div>
              </div>
            </div>
          </div>
        )}

        {activeTab === 'network' && (
          <div className="space-y-6">
            <div>
              <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">
                Network Settings
              </h3>
              
              <div className="space-y-4">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="bg-gray-50 dark:bg-gray-700 rounded-lg p-4">
                    <h4 className="text-sm font-medium text-gray-900 dark:text-white mb-2">
                      Connection Status
                    </h4>
                    <div className="flex items-center space-x-2">
                      <div className="w-2 h-2 bg-green-500 rounded-full"></div>
                      <span className="text-sm text-gray-600 dark:text-gray-400">Connected</span>
                    </div>
                  </div>
                  
                  <div className="bg-gray-50 dark:bg-gray-700 rounded-lg p-4">
                    <h4 className="text-sm font-medium text-gray-900 dark:text-white mb-2">
                      Local IP
                    </h4>
                    <span className="text-sm text-gray-600 dark:text-gray-400">
                      192.168.1.105
                    </span>
                  </div>
                </div>

                <div className="bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-lg p-4">
                  <div className="flex items-start space-x-3">
                    <div className="w-6 h-6 bg-blue-100 dark:bg-blue-900 rounded-lg flex items-center justify-center flex-shrink-0 mt-0.5">
                      <svg className="w-4 h-4 text-blue-600 dark:text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                      </svg>
                    </div>
                    <div>
                      <h4 className="text-sm font-medium text-blue-900 dark:text-blue-100 mb-1">
                        Network Discovery
                      </h4>
                      <p className="text-sm text-blue-800 dark:text-blue-200">
                        SwiftShare uses local network discovery to find other devices. 
                        Make sure all devices are on the same WiFi network.
                      </p>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        )}

        {activeTab === 'about' && (
          <div className="space-y-6">
            <div>
              <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">
                About SwiftShare
              </h3>
              
              <div className="space-y-4">
                <div className="bg-gray-50 dark:bg-gray-700 rounded-lg p-4">
                  <h4 className="text-sm font-medium text-gray-900 dark:text-white mb-2">
                    Version
                  </h4>
                  <span className="text-sm text-gray-600 dark:text-gray-400">
                    1.0.0
                  </span>
                </div>
                
                <div className="bg-gray-50 dark:bg-gray-700 rounded-lg p-4">
                  <h4 className="text-sm font-medium text-gray-900 dark:text-white mb-2">
                    License
                  </h4>
                  <span className="text-sm text-gray-600 dark:text-gray-400">
                    MIT License
                  </span>
                </div>
                
                <div className="bg-gray-50 dark:bg-gray-700 rounded-lg p-4">
                  <h4 className="text-sm font-medium text-gray-900 dark:text-white mb-2">
                    Description
                  </h4>
                  <p className="text-sm text-gray-600 dark:text-gray-400">
                    SwiftShare is a fast, secure, and easy-to-use file sharing application 
                    that allows you to transfer files between devices on your local network.
                  </p>
                </div>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default Settings; 