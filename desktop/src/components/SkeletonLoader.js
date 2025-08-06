import React from 'react';

const SkeletonLoader = ({ type = 'card', count = 3 }) => {
  const renderCardSkeleton = () => (
    <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-4 animate-pulse">
      <div className="flex items-center justify-between mb-3">
        <div className="flex items-center space-x-3">
          <div className="w-8 h-8 bg-gray-300 dark:bg-gray-600 rounded-lg"></div>
          <div className="flex-1">
            <div className="h-4 bg-gray-300 dark:bg-gray-600 rounded w-24 mb-2"></div>
            <div className="h-3 bg-gray-200 dark:bg-gray-700 rounded w-32"></div>
          </div>
        </div>
        <div className="w-16 h-6 bg-gray-300 dark:bg-gray-600 rounded-full"></div>
      </div>
      
      <div className="space-y-2 mb-4">
        <div className="flex justify-between">
          <div className="h-3 bg-gray-200 dark:bg-gray-700 rounded w-12"></div>
          <div className="h-3 bg-gray-300 dark:bg-gray-600 rounded w-16"></div>
        </div>
        <div className="flex justify-between">
          <div className="h-3 bg-gray-200 dark:bg-gray-700 rounded w-16"></div>
          <div className="h-3 bg-gray-300 dark:bg-gray-600 rounded w-20"></div>
        </div>
      </div>
      
      <div className="flex space-x-2">
        <div className="flex-1 h-8 bg-gray-300 dark:bg-gray-600 rounded-lg"></div>
        <div className="w-8 h-8 bg-gray-200 dark:bg-gray-700 rounded-lg"></div>
      </div>
    </div>
  );

  const renderListSkeleton = () => (
    <div className="space-y-3">
      {Array.from({ length: count }).map((_, index) => (
        <div key={index} className="flex items-center space-x-3 p-3 bg-gray-50 dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 animate-pulse">
          <div className="w-8 h-8 bg-gray-300 dark:bg-gray-600 rounded-lg"></div>
          <div className="flex-1">
            <div className="h-4 bg-gray-300 dark:bg-gray-600 rounded w-32 mb-1"></div>
            <div className="h-3 bg-gray-200 dark:bg-gray-700 rounded w-24"></div>
          </div>
          <div className="w-6 h-6 bg-gray-200 dark:bg-gray-700 rounded"></div>
        </div>
      ))}
    </div>
  );

  const renderGridSkeleton = () => (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
      {Array.from({ length: count }).map((_, index) => (
        <div key={index} className="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-4 animate-pulse">
          <div className="flex items-center space-x-3 mb-3">
            <div className="w-10 h-10 bg-gray-300 dark:bg-gray-600 rounded-lg"></div>
            <div className="flex-1">
              <div className="h-4 bg-gray-300 dark:bg-gray-600 rounded w-20 mb-2"></div>
              <div className="h-3 bg-gray-200 dark:bg-gray-700 rounded w-24"></div>
            </div>
          </div>
          
          <div className="space-y-2 mb-4">
            <div className="flex justify-between">
              <div className="h-3 bg-gray-200 dark:bg-gray-700 rounded w-8"></div>
              <div className="h-3 bg-gray-300 dark:bg-gray-600 rounded w-12"></div>
            </div>
            <div className="flex justify-between">
              <div className="h-3 bg-gray-200 dark:bg-gray-700 rounded w-16"></div>
              <div className="h-3 bg-gray-300 dark:bg-gray-600 rounded w-20"></div>
            </div>
          </div>
          
          <div className="flex space-x-2">
            <div className="flex-1 h-8 bg-gray-300 dark:bg-gray-600 rounded-lg"></div>
            <div className="w-8 h-8 bg-gray-200 dark:bg-gray-700 rounded-lg"></div>
          </div>
        </div>
      ))}
    </div>
  );

  switch (type) {
    case 'list':
      return renderListSkeleton();
    case 'grid':
      return renderGridSkeleton();
    case 'card':
    default:
      return (
        <div className="space-y-4">
          {Array.from({ length: count }).map((_, index) => (
            <div key={index}>{renderCardSkeleton()}</div>
          ))}
        </div>
      );
  }
};

export default SkeletonLoader; 