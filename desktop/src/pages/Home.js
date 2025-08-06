import React, { useEffect, useState } from 'react';
import { useStore } from '../store/store';
import DeviceCard from '../components/DeviceCard';
import TransferCard from '../components/TransferCard';
import FileDropZone from '../components/FileDropZone';
import SkeletonLoader from '../components/SkeletonLoader';

const Home = ({ showToast }) => {
  const { 
    devices, 
    transfers, 
    selectedFiles, 
    isConnected, 
    isScanning, 
    error, 
    loading,
    startDeviceScan,
    getActiveTransfers,
    getCompletedTransfers
  } = useStore();

  const [activeTransfers, setActiveTransfers] = useState([]);
  const [recentTransfers, setRecentTransfers] = useState([]);

  useEffect(() => {
    // Auto-scan for devices if connected
    if (isConnected && !isScanning) {
      startDeviceScan();
    }
  }, [isConnected, isScanning, startDeviceScan]);

  useEffect(() => {
    // Filter active and recent transfers
    setActiveTransfers(getActiveTransfers());
    setRecentTransfers(getCompletedTransfers().slice(0, 3));
  }, [transfers, getActiveTransfers, getCompletedTransfers]);

  const handleSendToDevice = (device) => {
    if (selectedFiles.length > 0) {
      showToast(`Sending ${selectedFiles.length} file(s) to ${device.name}`, 'success');
    }
  };

  const onlineDevices = devices.filter(d => d.online);
  const offlineDevices = devices.filter(d => !d.online);

  return (
    <div className="space-y-6">
      {/* Welcome Header */}
      <div className="text-center space-y-2">
        <h1 className="text-3xl font-bold text-gray-900 dark:text-white">
          Welcome to SwiftShare
        </h1>
        <p className="text-gray-600 dark:text-gray-400">
          Share files instantly across your devices
        </p>
      </div>

      {/* Error Banner */}
      {error && (
        <div className="p-4 bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg">
          <div className="flex items-center space-x-2">
            <svg className="w-5 h-5 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            <span className="text-red-800 dark:text-red-200">{error}</span>
          </div>
        </div>
      )}

      {/* File Drop Zone */}
      <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-6">
        <h2 className="text-xl font-semibold text-gray-900 dark:text-white mb-4">
          Send Files
        </h2>
        <FileDropZone />
      </div>

      {/* Active Transfers */}
      {activeTransfers.length > 0 && (
        <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-6">
          <h2 className="text-xl font-semibold text-gray-900 dark:text-white mb-4">
            Active Transfers ({activeTransfers.length})
          </h2>
          <div className="space-y-4">
            {activeTransfers.map(transfer => (
              <TransferCard key={transfer.id} transfer={transfer} />
            ))}
          </div>
        </div>
      )}

      {/* Recent Transfers */}
      {recentTransfers.length > 0 && (
        <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-6">
          <h2 className="text-xl font-semibold text-gray-900 dark:text-white mb-4">
            Recent Transfers
          </h2>
          <div className="space-y-4">
            {recentTransfers.map(transfer => (
              <TransferCard key={transfer.id} transfer={transfer} />
            ))}
          </div>
        </div>
      )}

      {/* Available Devices */}
      <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-6">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-xl font-semibold text-gray-900 dark:text-white">
            Available Devices ({devices.length})
          </h2>
          <button
            onClick={startDeviceScan}
            disabled={isScanning}
            className={`px-4 py-2 rounded-lg text-sm font-medium transition-all duration-200 ${
              isScanning
                ? 'bg-gray-100 dark:bg-gray-700 text-gray-400 cursor-not-allowed'
                : 'bg-blue-600 hover:bg-blue-700 text-white shadow-sm hover:shadow-md'
            }`}
          >
            {isScanning ? (
              <div className="flex items-center space-x-2">
                <svg className="w-4 h-4 animate-spin" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                </svg>
                <span>Scanning...</span>
              </div>
            ) : (
              <div className="flex items-center space-x-2">
                <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                </svg>
                <span>Scan for Devices</span>
              </div>
            )}
          </button>
        </div>

        {loading ? (
          <SkeletonLoader type="grid" count={3} />
        ) : devices.length > 0 ? (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {devices.map(device => (
              <DeviceCard 
                key={device.id} 
                device={device} 
                onSendFiles={() => handleSendToDevice(device)}
              />
            ))}
          </div>
        ) : (
          <div className="text-center py-8">
            <div className="text-4xl mb-4">🔍</div>
            <h3 className="text-lg font-medium text-gray-900 dark:text-white mb-2">
              No devices found
            </h3>
            <p className="text-gray-500 dark:text-gray-400 mb-4">
              Make sure other devices are running SwiftShare and on the same network
            </p>
            <button
              onClick={startDeviceScan}
              className="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition-colors"
            >
              Scan Again
            </button>
          </div>
        )}
      </div>

      {/* Quick Stats */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-4">
          <div className="flex items-center space-x-3">
            <div className="w-10 h-10 bg-blue-100 dark:bg-blue-900 rounded-lg flex items-center justify-center">
              <svg className="w-5 h-5 text-blue-600 dark:text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            </div>
            <div>
              <p className="text-sm text-gray-500 dark:text-gray-400">Online Devices</p>
              <p className="text-2xl font-bold text-gray-900 dark:text-white">{onlineDevices.length}</p>
            </div>
          </div>
        </div>

        <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-4">
          <div className="flex items-center space-x-3">
            <div className="w-10 h-10 bg-green-100 dark:bg-green-900 rounded-lg flex items-center justify-center">
              <svg className="w-5 h-5 text-green-600 dark:text-green-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M9 19l3 3m0 0l3-3m-3 3V10" />
              </svg>
            </div>
            <div>
              <p className="text-sm text-gray-500 dark:text-gray-400">Active Transfers</p>
              <p className="text-2xl font-bold text-gray-900 dark:text-white">{activeTransfers.length}</p>
            </div>
          </div>
        </div>

        <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-4">
          <div className="flex items-center space-x-3">
            <div className="w-10 h-10 bg-purple-100 dark:bg-purple-900 rounded-lg flex items-center justify-center">
              <svg className="w-5 h-5 text-purple-600 dark:text-purple-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
              </svg>
            </div>
            <div>
              <p className="text-sm text-gray-500 dark:text-gray-400">Selected Files</p>
              <p className="text-2xl font-bold text-gray-900 dark:text-white">{selectedFiles.length}</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Home; 