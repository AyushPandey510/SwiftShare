import React, { useState } from 'react';
import { useStore } from '../store/store';
import Tooltip from './Tooltip';

const DeviceCard = ({ device }) => {
  const { selectedFiles, startTransfer } = useStore();
  const [isHovered, setIsHovered] = useState(false);
  const [isClicked, setIsClicked] = useState(false);

  const handleSendFiles = () => {
    if (selectedFiles.length > 0) {
      startTransfer(device.id, selectedFiles);
      setIsClicked(true);
      setTimeout(() => setIsClicked(false), 200);
    }
  };

  const getDeviceIcon = (type) => {
    switch (type) {
      case 'mobile':
        return '📱';
      case 'desktop':
        return '💻';
      case 'tablet':
        return '📱';
      default:
        return '🖥️';
    }
  };

  const getStatusColor = (online) => {
    return online ? 'bg-green-500' : 'bg-gray-400';
  };

  const getStatusText = (online) => {
    return online ? 'Online' : 'Offline';
  };

  const formatLastSeen = (lastSeen) => {
    if (!lastSeen) return 'Unknown';
    const now = new Date();
    const last = new Date(lastSeen);
    const diffMs = now - last;
    const diffMins = Math.floor(diffMs / 60000);
    
    if (diffMins < 1) return 'Just now';
    if (diffMins < 60) return `${diffMins}m ago`;
    const diffHours = Math.floor(diffMins / 60);
    if (diffHours < 24) return `${diffHours}h ago`;
    const diffDays = Math.floor(diffHours / 24);
    return `${diffDays}d ago`;
  };

  const formatFileSize = (bytes) => {
    if (bytes === 0) return '0 B';
    const k = 1024;
    const sizes = ['B', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(1)) + ' ' + sizes[i];
  };

  const hasSelectedFiles = selectedFiles.length > 0;

  return (
    <div
      className={`relative bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-4 transition-all duration-200 hover:shadow-md hover:scale-[1.02] ${
        isHovered ? 'ring-2 ring-blue-500/20' : ''
      } ${isClicked ? 'scale-95' : ''}`}
      onMouseEnter={() => setIsHovered(true)}
      onMouseLeave={() => setIsHovered(false)}
    >
      {/* Status indicator */}
      <div className="absolute top-3 right-3 flex items-center space-x-2">
        <div className={`w-2 h-2 rounded-full ${getStatusColor(device.online)} animate-pulse`} />
        <span className="text-xs text-gray-500 dark:text-gray-400">
          {getStatusText(device.online)}
        </span>
      </div>

      {/* Device icon and name */}
      <div className="flex items-center space-x-3 mb-3">
        <div className="text-2xl">{getDeviceIcon(device.type)}</div>
        <div className="flex-1 min-w-0">
          <h3 className="font-semibold text-gray-900 dark:text-white truncate">
            {device.name}
          </h3>
          <p className="text-sm text-gray-500 dark:text-gray-400">
            {device.ip}:{device.port}
          </p>
        </div>
      </div>

      {/* Device details */}
      <div className="space-y-2 mb-4">
        <div className="flex justify-between text-sm">
          <span className="text-gray-500 dark:text-gray-400">Type:</span>
          <span className="text-gray-900 dark:text-white capitalize">{device.type}</span>
        </div>
        <div className="flex justify-between text-sm">
          <span className="text-gray-500 dark:text-gray-400">Last seen:</span>
          <span className="text-gray-900 dark:text-white">{formatLastSeen(device.lastSeen)}</span>
        </div>
        {device.capabilities && (
          <div className="flex justify-between text-sm">
            <span className="text-gray-500 dark:text-gray-400">Capabilities:</span>
            <span className="text-gray-900 dark:text-white">{device.capabilities.join(', ')}</span>
          </div>
        )}
      </div>

      {/* Action buttons */}
      <div className="flex space-x-2">
        <Tooltip text="Send files to this device">
          <button
            onClick={handleSendFiles}
            disabled={!hasSelectedFiles || !device.online}
            className={`flex-1 px-3 py-2 rounded-lg text-sm font-medium transition-all duration-200 ${
              hasSelectedFiles && device.online
                ? 'bg-blue-600 hover:bg-blue-700 text-white shadow-sm hover:shadow-md'
                : 'bg-gray-100 dark:bg-gray-700 text-gray-400 cursor-not-allowed'
            } ${isClicked ? 'scale-95' : ''}`}
          >
            {hasSelectedFiles ? `Send ${selectedFiles.length} file${selectedFiles.length > 1 ? 's' : ''}` : 'No files selected'}
          </button>
        </Tooltip>
        
        <Tooltip text="View device details">
          <button
            className="px-3 py-2 rounded-lg bg-gray-100 dark:bg-gray-700 text-gray-600 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors duration-200"
          >
            <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
            </svg>
          </button>
        </Tooltip>
      </div>

      {/* Quick info */}
      {device.online && (
        <div className="mt-3 pt-3 border-t border-gray-200 dark:border-gray-700">
          <div className="flex justify-between text-xs text-gray-500 dark:text-gray-400">
            <span>Version:</span>
            <span>{device.version || 'Unknown'}</span>
          </div>
        </div>
      )}
    </div>
  );
};

export default DeviceCard; 