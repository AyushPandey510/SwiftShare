import React, { useState, useCallback } from 'react';
import { useDropzone } from 'react-dropzone';
import { useStore } from '../store/store';
import Tooltip from './Tooltip';

const FileDropZone = () => {
  const { selectedFiles, addSelectedFile, removeSelectedFile } = useStore();
  const [isDragOver, setIsDragOver] = useState(false);
  const [dragError, setDragError] = useState('');

  const onDrop = useCallback((acceptedFiles, rejectedFiles) => {
    setDragError('');
    
    // Handle rejected files
    if (rejectedFiles.length > 0) {
      const errors = rejectedFiles.map(file => {
        if (file.errors.some(e => e.code === 'file-too-large')) {
          return `${file.file.name} is too large`;
        }
        if (file.errors.some(e => e.code === 'file-invalid-type')) {
          return `${file.file.name} is not a supported file type`;
        }
        return `${file.file.name} was rejected`;
      });
      setDragError(errors.join(', '));
    }

    // Add accepted files
    acceptedFiles.forEach(file => {
      addSelectedFile({
        id: `${file.name}-${Date.now()}`,
        name: file.name,
        size: file.size,
        type: file.type,
        lastModified: file.lastModified,
        file: file
      });
    });
  }, [addSelectedFile]);

  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop,
    accept: {
      'image/*': ['.jpeg', '.jpg', '.png', '.gif', '.bmp', '.webp'],
      'video/*': ['.mp4', '.avi', '.mov', '.wmv', '.flv', '.webm'],
      'audio/*': ['.mp3', '.wav', '.flac', '.aac', '.ogg'],
      'application/pdf': ['.pdf'],
      'text/*': ['.txt', '.md', '.json', '.xml', '.csv'],
      'application/zip': ['.zip', '.rar', '.7z'],
      'application/msword': ['.doc', '.docx'],
      'application/vnd.ms-excel': ['.xls', '.xlsx'],
      'application/vnd.ms-powerpoint': ['.ppt', '.pptx']
    },
    maxSize: 100 * 1024 * 1024, // 100MB
    multiple: true
  });

  const formatFileSize = (bytes) => {
    if (bytes === 0) return '0 B';
    const k = 1024;
    const sizes = ['B', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(1)) + ' ' + sizes[i];
  };

  const getFileIcon = (type) => {
    if (type.startsWith('image/')) return '🖼️';
    if (type.startsWith('video/')) return '🎥';
    if (type.startsWith('audio/')) return '🎵';
    if (type === 'application/pdf') return '📄';
    if (type.startsWith('text/')) return '📝';
    if (type.includes('zip') || type.includes('rar') || type.includes('7z')) return '📦';
    if (type.includes('word')) return '📄';
    if (type.includes('excel')) return '📊';
    if (type.includes('powerpoint')) return '📊';
    return '📄';
  };

  const handleRemoveFile = (fileId) => {
    removeSelectedFile(fileId);
  };

  const handleClearAll = () => {
    selectedFiles.forEach(file => removeSelectedFile(file.id));
  };

  return (
    <div className="space-y-4">
      {/* Drop Zone */}
      <div
        {...getRootProps()}
        className={`border-2 border-dashed rounded-xl p-8 text-center transition-all duration-200 cursor-pointer ${
          isDragActive || isDragOver
            ? 'border-blue-500 bg-blue-50 dark:bg-blue-900/20 scale-[1.02]'
            : 'border-gray-300 dark:border-gray-600 hover:border-gray-400 dark:hover:border-gray-500'
        }`}
        onDragEnter={() => setIsDragOver(true)}
        onDragLeave={() => setIsDragOver(false)}
      >
        <input {...getInputProps()} />
        
        <div className="space-y-4">
          <div className="text-4xl">📁</div>
          
          <div>
            <p className="text-lg font-medium text-gray-900 dark:text-white mb-2">
              {isDragActive ? 'Drop files here' : 'Drag & drop files here'}
            </p>
            <p className="text-sm text-gray-500 dark:text-gray-400">
              or click to browse files
            </p>
          </div>
          
          <div className="text-xs text-gray-400 dark:text-gray-500">
            Supports: Images, Videos, Audio, Documents, Archives (Max 100MB each)
          </div>
        </div>
      </div>

      {/* Error Message */}
      {dragError && (
        <div className="p-3 bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg">
          <div className="text-sm text-red-600 dark:text-red-400">
            {dragError}
          </div>
        </div>
      )}

      {/* Selected Files */}
      {selectedFiles.length > 0 && (
        <div className="space-y-3">
          <div className="flex items-center justify-between">
            <h3 className="text-sm font-medium text-gray-900 dark:text-white">
              Selected Files ({selectedFiles.length})
            </h3>
            
            <Tooltip text="Clear all files">
              <button
                onClick={handleClearAll}
                className="text-sm text-red-600 dark:text-red-400 hover:text-red-700 dark:hover:text-red-300 transition-colors"
              >
                Clear All
              </button>
            </Tooltip>
          </div>
          
          <div className="space-y-2 max-h-60 overflow-y-auto">
            {selectedFiles.map((file) => (
              <div
                key={file.id}
                className="flex items-center space-x-3 p-3 bg-gray-50 dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700"
              >
                <div className="text-xl">{getFileIcon(file.type)}</div>
                
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-medium text-gray-900 dark:text-white truncate">
                    {file.name}
                  </p>
                  <p className="text-xs text-gray-500 dark:text-gray-400">
                    {formatFileSize(file.size)} • {new Date(file.lastModified).toLocaleDateString()}
                  </p>
                </div>
                
                <Tooltip text="Remove file">
                  <button
                    onClick={() => handleRemoveFile(file.id)}
                    className="p-1 text-gray-400 hover:text-red-500 transition-colors"
                  >
                    <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                    </svg>
                  </button>
                </Tooltip>
              </div>
            ))}
          </div>
          
          {/* Total Size */}
          <div className="text-sm text-gray-500 dark:text-gray-400 text-center">
            Total: {formatFileSize(selectedFiles.reduce((sum, file) => sum + file.size, 0))}
          </div>
        </div>
      )}
    </div>
  );
};

export default FileDropZone; 