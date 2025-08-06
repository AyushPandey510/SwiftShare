import React, { useState, useEffect } from 'react';
import { useStore } from '../store/store';
import TransferCard from '../components/TransferCard';
import SkeletonLoader from '../components/SkeletonLoader';

const Transfers = ({ showToast }) => {
  const { transfers, clearTransferHistory, loading } = useStore();
  const [filter, setFilter] = useState('all');
  const [filteredTransfers, setFilteredTransfers] = useState([]);

  useEffect(() => {
    // Filter transfers based on selected filter
    switch (filter) {
      case 'active':
        setFilteredTransfers(transfers.filter(t => 
          t.status === 'in_progress' || t.status === 'uploading' || t.status === 'downloading'
        ));
        break;
      case 'completed':
        setFilteredTransfers(transfers.filter(t => t.status === 'completed'));
        break;
      case 'failed':
        setFilteredTransfers(transfers.filter(t => t.status === 'failed'));
        break;
      case 'cancelled':
        setFilteredTransfers(transfers.filter(t => t.status === 'cancelled'));
        break;
      default:
        setFilteredTransfers(transfers);
    }
  }, [transfers, filter]);

  const handleClearHistory = () => {
    if (window.confirm('Are you sure you want to clear all transfer history? This action cannot be undone.')) {
      clearTransferHistory();
      showToast('Transfer history cleared', 'success');
    }
  };

  const getTransferStats = () => {
    const total = transfers.length;
    const active = transfers.filter(t => 
      t.status === 'in_progress' || t.status === 'uploading' || t.status === 'downloading'
    ).length;
    const completed = transfers.filter(t => t.status === 'completed').length;
    const failed = transfers.filter(t => t.status === 'failed').length;
    const cancelled = transfers.filter(t => t.status === 'cancelled').length;

    return { total, active, completed, failed, cancelled };
  };

  const stats = getTransferStats();

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900 dark:text-white">
            Transfers
          </h1>
          <p className="text-gray-600 dark:text-gray-400 mt-1">
            Monitor and manage your file transfers
          </p>
        </div>
        
        {transfers.length > 0 && (
          <button
            onClick={handleClearHistory}
            className="px-4 py-2 bg-red-600 hover:bg-red-700 text-white rounded-lg font-medium transition-colors"
          >
            Clear History
          </button>
        )}
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-2 md:grid-cols-5 gap-4">
        <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-4">
          <div className="flex items-center space-x-3">
            <div className="w-8 h-8 bg-blue-100 dark:bg-blue-900 rounded-lg flex items-center justify-center">
              <svg className="w-4 h-4 text-blue-600 dark:text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
              </svg>
            </div>
            <div>
              <p className="text-sm text-gray-500 dark:text-gray-400">Total</p>
              <p className="text-lg font-semibold text-gray-900 dark:text-white">{stats.total}</p>
            </div>
          </div>
        </div>

        <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-4">
          <div className="flex items-center space-x-3">
            <div className="w-8 h-8 bg-green-100 dark:bg-green-900 rounded-lg flex items-center justify-center">
              <svg className="w-4 h-4 text-green-600 dark:text-green-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M9 19l3 3m0 0l3-3m-3 3V10" />
              </svg>
            </div>
            <div>
              <p className="text-sm text-gray-500 dark:text-gray-400">Active</p>
              <p className="text-lg font-semibold text-gray-900 dark:text-white">{stats.active}</p>
            </div>
          </div>
        </div>

        <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-4">
          <div className="flex items-center space-x-3">
            <div className="w-8 h-8 bg-blue-100 dark:bg-blue-900 rounded-lg flex items-center justify-center">
              <svg className="w-4 h-4 text-blue-600 dark:text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
              </svg>
            </div>
            <div>
              <p className="text-sm text-gray-500 dark:text-gray-400">Completed</p>
              <p className="text-lg font-semibold text-gray-900 dark:text-white">{stats.completed}</p>
            </div>
          </div>
        </div>

        <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-4">
          <div className="flex items-center space-x-3">
            <div className="w-8 h-8 bg-red-100 dark:bg-red-900 rounded-lg flex items-center justify-center">
              <svg className="w-4 h-4 text-red-600 dark:text-red-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
              </svg>
            </div>
            <div>
              <p className="text-sm text-gray-500 dark:text-gray-400">Failed</p>
              <p className="text-lg font-semibold text-gray-900 dark:text-white">{stats.failed}</p>
            </div>
          </div>
        </div>

        <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-4">
          <div className="flex items-center space-x-3">
            <div className="w-8 h-8 bg-gray-100 dark:bg-gray-700 rounded-lg flex items-center justify-center">
              <svg className="w-4 h-4 text-gray-600 dark:text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
              </svg>
            </div>
            <div>
              <p className="text-sm text-gray-500 dark:text-gray-400">Cancelled</p>
              <p className="text-lg font-semibold text-gray-900 dark:text-white">{stats.cancelled}</p>
            </div>
          </div>
        </div>
      </div>

      {/* Filter Pills */}
      {transfers.length > 0 && (
        <div className="flex flex-wrap gap-2">
          {[
            { key: 'all', label: 'All', count: stats.total },
            { key: 'active', label: 'Active', count: stats.active },
            { key: 'completed', label: 'Completed', count: stats.completed },
            { key: 'failed', label: 'Failed', count: stats.failed },
            { key: 'cancelled', label: 'Cancelled', count: stats.cancelled }
          ].map(({ key, label, count }) => (
            <button
              key={key}
              onClick={() => setFilter(key)}
              className={`px-4 py-2 rounded-full text-sm font-medium transition-all duration-200 ${
                filter === key
                  ? 'bg-blue-600 text-white shadow-sm'
                  : 'bg-gray-100 dark:bg-gray-700 text-gray-600 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-gray-600'
              }`}
            >
              {label} ({count})
            </button>
          ))}
        </div>
      )}

      {/* Transfers List */}
      <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-6">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-xl font-semibold text-gray-900 dark:text-white">
            Transfer History
          </h2>
          {filteredTransfers.length > 0 && (
            <span className="text-sm text-gray-500 dark:text-gray-400">
              {filteredTransfers.length} transfer{filteredTransfers.length !== 1 ? 's' : ''}
            </span>
          )}
        </div>

        {loading ? (
          <SkeletonLoader type="card" count={3} />
        ) : filteredTransfers.length > 0 ? (
          <div className="space-y-4">
            {filteredTransfers.map(transfer => (
              <TransferCard key={transfer.id} transfer={transfer} />
            ))}
          </div>
        ) : (
          <div className="text-center py-12">
            <div className="text-4xl mb-4">📤</div>
            <h3 className="text-lg font-medium text-gray-900 dark:text-white mb-2">
              {filter === 'all' ? 'No transfers yet' : `No ${filter} transfers`}
            </h3>
            <p className="text-gray-500 dark:text-gray-400">
              {filter === 'all' 
                ? 'Start sharing files to see your transfer history here'
                : `No ${filter} transfers found in your history`
              }
            </p>
          </div>
        )}
      </div>
    </div>
  );
};

export default Transfers; 