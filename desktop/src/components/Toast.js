import React, { useEffect } from 'react';

const Toast = ({ message, type = 'info', onClose, duration = 3000 }) => {
  useEffect(() => {
    if (!message) return;
    const timer = setTimeout(() => {
      onClose();
    }, duration);
    return () => clearTimeout(timer);
  }, [message, duration, onClose]);

  if (!message) return null;

  let bg = 'bg-gray-800';
  if (type === 'success') bg = 'bg-green-600';
  if (type === 'error') bg = 'bg-red-600';
  if (type === 'info') bg = 'bg-blue-600';

  return (
    <div
      className={`fixed bottom-6 left-1/2 transform -translate-x-1/2 z-50 px-6 py-3 rounded-lg shadow-lg text-white text-sm font-medium animate-fade-in ${bg}`}
      role="alert"
      aria-live="assertive"
    >
      {message}
      <button
        onClick={onClose}
        className="ml-4 text-white/80 hover:text-white text-lg font-bold focus:outline-none"
        aria-label="Close notification"
      >
        ×
      </button>
    </div>
  );
};

export default Toast; 