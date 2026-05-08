import React, { useEffect } from 'react';
import { useStore } from '../store/store';
import DeviceCard from '../components/DeviceCard';
import SkeletonLoader from '../components/SkeletonLoader';

const Devices = ({ showToast }) => {
  const { 
    devices, 
    isScanning, 
    scanForDevices, 
    localIp, 
    loading 
  } = useStore();

  useEffect(() => {
    // Auto-scan on mount
    if (!isScanning && devices.length === 0) {
      scanForDevices();
    }
  }, [isScanning, devices.length, scanForDevices]);

  const onlineDevices = devices.filter(d => d.online);
  const offlineDevices = devices.filter(d => !d.online);
  const mobileDevices = devices.filter(d => d.type === 'mobile');
  const desktopDevices = devices.filter(d => d.type === 'desktop');

  const handleScan = async () => {
    try {
      await scanForDevices();
      showToast('Device scan completed', 'success');
    } catch (error) {
      showToast('Failed to scan for devices', 'error');
    }
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900 dark:text-white">
            Devices
          </h1>
          <p className="text-gray-600 dark:text-gray-400 mt-1">
            Discover and manage devices on your network
          </p>
        </div>
        
        <button
          onClick={handleScan}
          disabled={isScanning}
          className={`px-6 py-3 rounded-lg font-medium transition-all duration-200 ${
            isScanning
              ? 'bg-gray-100 dark:bg-gray-700 text-gray-400 cursor-not-allowed'
              : 'bg-blue-600 hover:bg-blue-700 text-white shadow-sm hover:shadow-md'
          }`}
        >
          {isScanning ? (
            <div className="flex items-center space-x-2">
              <svg className="w-5 h-5 animate-spin" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
              </svg>
              <span>Scanning...</span>
            </div>
          ) : (
            <div className="flex items-center space-x-2">
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
              </svg>
              <span>Scan for Devices</span>
            </div>
          )}
        </button>
      </div>

      {/* Network Information */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-4">
          <div className="flex items-center space-x-3">
            <div className="w-10 h-10 bg-blue-100 dark:bg-blue-900 rounded-lg flex items-center justify-center">
              <svg className="w-5 h-5 text-blue-600 dark:text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8.111 16.404a5.5 5.5 0 017.778 0M12 20h.01m-7.08-7.071c3.904-3.905 10.236-3.905 14.141 0M1.394 9.393c5.857-5.857 15.355-5.857 21.213 0" />
              </svg>
            </div>
            <div>
              <p className="text-sm text-gray-500 dark:text-gray-400">Local IP</p>
              <p className="text-lg font-semibold text-gray-900 dark:text-white">
                {localIp || 'Detecting...'}
              </p>
            </div>
          </div>
        </div>

        <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-4">
          <div className="flex items-center space-x-3">
            <div className="w-10 h-10 bg-green-100 dark:bg-green-900 rounded-lg flex items-center justify-center">
              <svg className="w-5 h-5 text-green-600 dark:text-green-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            </div>
            <div>
              <p className="text-sm text-gray-500 dark:text-gray-400">Online Devices</p>
              <p className="text-lg font-semibold text-gray-900 dark:text-white">
                {onlineDevices.length}
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Loading State */}
      {loading && (
        <div className="space-y-6">
          <SkeletonLoader type="grid" count={6} />
        </div>
      )}

      {/* Device Categories */}
      {!loading && (
        <div className="space-y-6">
          {/* Mobile Devices */}
          <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-6">
            <div className="flex items-center space-x-2 mb-4">
              <div className="w-8 h-8 bg-blue-100 dark:bg-blue-900 rounded-lg flex items-center justify-center">
                <span className="text-lg">📱</span>
              </div>
              <h2 className="text-xl font-semibold text-gray-900 dark:text-white">
                Mobile Devices ({mobileDevices.length})
              </h2>
            </div>
            
            {mobileDevices.length > 0 ? (
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                {mobileDevices.map(device => (
                  <DeviceCard key={device.id} device={device} />
                ))}
              </div>
            ) : (
              <div className="text-center py-8">
                <div className="text-4xl mb-4">📱</div>
                <h3 className="text-lg font-medium text-gray-900 dark:text-white mb-2">
                  No mobile devices found
                </h3>
                <p className="text-gray-500 dark:text-gray-400">
                  Mobile devices will appear here when discovered
                </p>
              </div>
            )}
          </div>

          {/* Desktop Devices */}
          <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-6">
            <div className="flex items-center space-x-2 mb-4">
              <div className="w-8 h-8 bg-purple-100 dark:bg-purple-900 rounded-lg flex items-center justify-center">
                <span className="text-lg">💻</span>
              </div>
              <h2 className="text-xl font-semibold text-gray-900 dark:text-white">
                Desktop Devices ({desktopDevices.length})
              </h2>
            </div>
            
            {desktopDevices.length > 0 ? (
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                {desktopDevices.map(device => (
                  <DeviceCard key={device.id} device={device} />
                ))}
              </div>
            ) : (
              <div className="text-center py-8">
                <div className="text-4xl mb-4">💻</div>
                <h3 className="text-lg font-medium text-gray-900 dark:text-white mb-2">
                  No desktop devices found
                </h3>
                <p className="text-gray-500 dark:text-gray-400">
                  Desktop devices will appear here when discovered
                </p>
              </div>
            )}
          </div>

          {/* Offline Devices */}
          {offlineDevices.length > 0 && (
            <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-6">
              <div className="flex items-center space-x-2 mb-4">
                <div className="w-8 h-8 bg-gray-100 dark:bg-gray-700 rounded-lg flex items-center justify-center">
                  <span className="text-lg">🔌</span>
                </div>
                <h2 className="text-xl font-semibold text-gray-900 dark:text-white">
                  Offline Devices ({offlineDevices.length})
                </h2>
              </div>
              
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                {offlineDevices.map(device => (
                  <DeviceCard key={device.id} device={device} />
                ))}
              </div>
            </div>
          )}
        </div>
      )}

      {/* Network Tips */}
      {!loading && devices.length === 0 && (
        <div className="bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-xl p-6">
          <div className="flex items-start space-x-3">
            <div className="w-6 h-6 bg-blue-100 dark:bg-blue-900 rounded-lg flex items-center justify-center flex-shrink-0 mt-0.5">
              <svg className="w-4 h-4 text-blue-600 dark:text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            </div>
            <div>
              <h3 className="text-lg font-semibold text-blue-900 dark:text-blue-100 mb-2">
                Network Discovery Tips
              </h3>
              <ul className="space-y-1 text-sm text-blue-800 dark:text-blue-200">
                <li>• Make sure all devices are on the same WiFi network</li>
                <li>• Ensure SwiftShare is running on other devices</li>
                <li>• Check that your firewall allows local network connections</li>
                <li>• Try scanning again if devices don't appear immediately</li>
              </ul>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default Devices; 