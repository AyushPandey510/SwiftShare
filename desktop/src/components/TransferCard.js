import React, { useState } from 'react';
import { useStore } from '../store/store';
import Tooltip from './Tooltip';

const TransferCard = ({ transfer }) => {
  const { removeTransfer } = useStore();
  const [isHovered, setIsHovered] = useState(false);

  const getStatusColor = (status) => {
    switch (status) {
      case 'completed':
        return 'text-green-600 bg-green-100 dark:bg-green-900 dark:text-green-400';
      case 'in_progress':
        return 'text-blue-600 bg-blue-100 dark:bg-blue-900 dark:text-blue-400';
      case 'failed':
        return 'text-red-600 bg-red-100 dark:bg-red-900 dark:text-red-400';
      case 'pending':
        return 'text-yellow-600 bg-yellow-100 dark:bg-yellow-900 dark:text-yellow-400';
      default:
        return 'text-gray-600 bg-gray-100 dark:bg-gray-700 dark:text-gray-400';
    }
  };

  const getStatusIcon = (status) => {
    switch (status) {
      case 'completed':
        return (
          <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
          </svg>
        );
      case 'in_progress':
        return (
          <svg className="w-4 h-4 animate-spin" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
          </svg>
        );
      case 'failed':
        return (
          <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
          </svg>
        );
      case 'pending':
        return (
          <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
        );
      default:
        return (
          <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
        );
    }
  };

  const formatFileSize = (bytes) => {
    if (bytes === 0) return '0 B';
    const k = 1024;
    const sizes = ['B', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(1)) + ' ' + sizes[i];
  };

  const formatTime = (date) => {
    if (!date) return 'Unknown';
    const now = new Date();
    const transferDate = new Date(date);
    const diffMs = now - transferDate;
    const diffMins = Math.floor(diffMs / 60000);
    
    if (diffMins < 1) return 'Just now';
    if (diffMins < 60) return `${diffMins}m ago`;
    const diffHours = Math.floor(diffMins / 60);
    if (diffHours < 24) return `${diffHours}h ago`;
    const diffDays = Math.floor(diffHours / 24);
    return `${diffDays}d ago`;
  };

  const getProgressPercentage = () => {
    if (transfer.status === 'completed') return 100;
    if (transfer.status === 'failed') return 0;
    return transfer.progress || 0;
  };

  const handleRemove = () => {
    removeTransfer(transfer.id);
  };

  return (
    <div
      className={`bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-4 transition-all duration-200 hover:shadow-md ${
        isHovered ? 'ring-2 ring-blue-500/20' : ''
      }`}
      onMouseEnter={() => setIsHovered(true)}
      onMouseLeave={() => setIsHovered(false)}
    >
      {/* Header with status */}
      <div className="flex items-center justify-between mb-3">
        <div className="flex items-center space-x-2">
          {getStatusIcon(transfer.status)}
          <span className={`px-2 py-1 rounded-full text-xs font-medium ${getStatusColor(transfer.status)}`}>
            {transfer.status.replace('_', ' ')}
          </span>
        </div>
        
        <div className="flex items-center space-x-2">
          <Tooltip text="Transfer details">
            <button className="p-1 text-gray-400 hover:text-gray-600 dark:hover:text-gray-300 transition-colors">
              <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            </button>
          </Tooltip>
          
          <Tooltip text="Remove transfer">
            <button
              onClick={handleRemove}
              className="p-1 text-gray-400 hover:text-red-500 transition-colors"
            >
              <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
              </svg>
            </button>
          </Tooltip>
        </div>
      </div>

      {/* Transfer info */}
      <div className="space-y-2 mb-3">
        <div className="flex justify-between text-sm">
          <span className="text-gray-500 dark:text-gray-400">Files:</span>
          <span className="text-gray-900 dark:text-white font-medium">
            {transfer.files?.length || 1} file{(transfer.files?.length || 1) > 1 ? 's' : ''}
          </span>
        </div>
        
        <div className="flex justify-between text-sm">
          <span className="text-gray-500 dark:text-gray-400">Size:</span>
          <span className="text-gray-900 dark:text-white">
            {formatFileSize(transfer.totalSize || 0)}
          </span>
        </div>
        
        <div className="flex justify-between text-sm">
          <span className="text-gray-500 dark:text-gray-400">Started:</span>
          <span className="text-gray-900 dark:text-white">
            {formatTime(transfer.startTime)}
          </span>
        </div>
      </div>

      {/* Progress bar */}
      <div className="mb-3">
        <div className="flex justify-between text-xs text-gray-500 dark:text-gray-400 mb-1">
          <span>Progress</span>
          <span>{getProgressPercentage()}%</span>
        </div>
        <div className="w-full bg-gray-200 dark:bg-gray-700 rounded-full h-2 overflow-hidden">
          <div
            className={`h-full rounded-full transition-all duration-300 ${
              transfer.status === 'completed' 
                ? 'bg-green-500' 
                : transfer.status === 'failed'
                ? 'bg-red-500'
                : 'bg-blue-500'
            }`}
            style={{ width: `${getProgressPercentage()}%` }}
          />
        </div>
      </div>

      {/* File list preview */}
      {transfer.files && transfer.files.length > 0 && (
        <div className="border-t border-gray-200 dark:border-gray-700 pt-3">
          <div className="text-xs text-gray-500 dark:text-gray-400 mb-2">Files:</div>
          <div className="space-y-1 max-h-20 overflow-y-auto">
            {transfer.files.slice(0, 3).map((file, index) => (
              <div key={index} className="flex items-center space-x-2 text-xs">
                <svg className="w-3 h-3 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                </svg>
                <span className="text-gray-600 dark:text-gray-300 truncate">{file.name}</span>
                <span className="text-gray-400 text-xs">{formatFileSize(file.size)}</span>
              </div>
            ))}
            {transfer.files.length > 3 && (
              <div className="text-xs text-gray-400 italic">
                +{transfer.files.length - 3} more files
              </div>
            )}
          </div>
        </div>
      )}

      {/* Error message if failed */}
      {transfer.status === 'failed' && transfer.error && (
        <div className="mt-3 p-2 bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg">
          <div className="text-xs text-red-600 dark:text-red-400">
            Error: {transfer.error}
          </div>
        </div>
      )}
    </div>
  );
};

export default TransferCard; 