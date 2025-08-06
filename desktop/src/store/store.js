import { create } from 'zustand';
import axios from 'axios';
import { io } from 'socket.io-client';

const API_BASE_URL = 'http://localhost:8082';

export const useStore = create((set, get) => ({
  // State
  devices: [],
  transfers: [],
  selectedFiles: [],
  isScanning: false,
  isConnected: false,
  error: null,
  loading: false,
  settings: {
    autoScan: true,
    encryption: false,
    compression: false,
    downloadPath: '',
  },
  theme: 'system',
  localIp: '',

  // Actions
  initializeApp: async () => {
    set({ loading: true, error: null });
    
    try {
      // Test backend connection
      const response = await axios.get(`${API_BASE_URL}/health`);
      if (response.status === 200) {
        set({ isConnected: true });
        
        // Initialize WebSocket connection
        const socket = io(API_BASE_URL);
        
        socket.on('connect', () => {
          set({ isConnected: true });
        });
        
        socket.on('disconnect', () => {
          set({ isConnected: false });
        });
        
        socket.on('device-found', (device) => {
          get().addDevice(device);
        });
        
        socket.on('transfer-progress', (progress) => {
          get().updateTransferProgress(progress);
        });
        
        // Load initial data
        await get().loadDevices();
        await get().loadTransfers();
        
      } else {
        set({ isConnected: false, error: 'Backend not responding' });
      }
    } catch (error) {
      set({ 
        isConnected: false, 
        error: 'Failed to connect to backend. Make sure the backend is running.' 
      });
    } finally {
      set({ loading: false });
    }
  },

  // Device management
  loadDevices: async () => {
    try {
      const response = await axios.get(`${API_BASE_URL}/api/devices`);
      set({ devices: response.data.devices || [] });
    } catch (error) {
      console.error('Failed to load devices:', error);
    }
  },

  addDevice: (device) => {
    set((state) => ({
      devices: [...state.devices.filter(d => d.id !== device.id), device]
    }));
  },

  removeDevice: (deviceId) => {
    set((state) => ({
      devices: state.devices.filter(d => d.id !== deviceId)
    }));
  },

  startDeviceScan: async () => {
    set({ isScanning: true });
    try {
      await get().loadDevices();
    } catch (error) {
      console.error('Device scan failed:', error);
    } finally {
      set({ isScanning: false });
    }
  },

  scanForDevices: async () => {
    await get().startDeviceScan();
  },

  // File management
  addSelectedFile: (file) => {
    set((state) => ({
      selectedFiles: [...state.selectedFiles, file]
    }));
  },

  removeSelectedFile: (fileId) => {
    set((state) => ({
      selectedFiles: state.selectedFiles.filter(f => f.id !== fileId)
    }));
  },

  selectFiles: (files) => {
    set({ selectedFiles: files });
  },

  // Transfer management
  startTransfer: async (deviceId, files) => {
    const filesToSend = files || get().selectedFiles;
    
    if (!filesToSend.length) {
      set({ error: 'No files selected' });
      return;
    }

    set({ loading: true, error: null });

    try {
      const transferPromises = filesToSend.map(async (file) => {
        const formData = new FormData();
        formData.append('file', file.file || file);
        formData.append('targetDevice', deviceId);
        
        const response = await axios.post(`${API_BASE_URL}/api/transfer`, formData, {
          headers: {
            'Content-Type': 'multipart/form-data',
          },
          onUploadProgress: (progressEvent) => {
            const progress = Math.round((progressEvent.loaded * 100) / progressEvent.total);
            get().updateTransferProgress({
              id: file.id || file.name,
              progress,
              filename: file.name,
              status: 'in_progress'
            });
          }
        });
        
        return response.data;
      });

      const results = await Promise.all(transferPromises);
      
      // Add transfers to state
      set((state) => ({
        transfers: [...state.transfers, ...results],
        selectedFiles: [],
        loading: false
      }));

    } catch (error) {
      set({ 
        error: 'Failed to send files: ' + error.message,
        loading: false 
      });
    }
  },

  sendFiles: async (targetDevice, files) => {
    await get().startTransfer(targetDevice.id, files);
  },

  loadTransfers: async () => {
    try {
      const response = await axios.get(`${API_BASE_URL}/api/transfers`);
      set({ transfers: response.data.transfers || [] });
    } catch (error) {
      console.error('Failed to load transfers:', error);
    }
  },

  updateTransferProgress: (progress) => {
    set((state) => ({
      transfers: state.transfers.map(t => 
        t.id === progress.id ? { ...t, ...progress } : t
      )
    }));
  },

  removeTransfer: (transferId) => {
    set((state) => ({
      transfers: state.transfers.filter(t => t.id !== transferId)
    }));
  },

  cancelTransfer: async (transferId) => {
    try {
      await axios.delete(`${API_BASE_URL}/api/transfer/${transferId}`);
      set((state) => ({
        transfers: state.transfers.map(t => 
          t.id === transferId ? { ...t, status: 'cancelled' } : t
        )
      }));
    } catch (error) {
      console.error('Failed to cancel transfer:', error);
    }
  },

  clearTransferHistory: () => {
    set({ transfers: [] });
  },

  // Settings
  updateSettings: (newSettings) => {
    set((state) => ({
      settings: { ...state.settings, ...newSettings }
    }));
  },

  setTheme: (theme) => set({ theme }),
  setLocalIp: (ip) => set({ localIp: ip }),

  // File operations
  openFileDialog: () => {
    // This would integrate with Electron's file dialog
    // For now, we'll simulate file selection
    const input = document.createElement('input');
    input.type = 'file';
    input.multiple = true;
    input.onchange = (e) => {
      const files = Array.from(e.target.files);
      get().selectFiles(files);
    };
    input.click();
  },

  // Utility functions
  clearError: () => set({ error: null }),
  
  getDeviceById: (deviceId) => {
    const { devices } = get();
    return devices.find(d => d.id === deviceId);
  },

  getTransferById: (transferId) => {
    const { transfers } = get();
    return transfers.find(t => t.id === transferId);
  },

  getActiveTransfers: () => {
    const { transfers } = get();
    return transfers.filter(t => 
      t.status === 'in_progress' || t.status === 'uploading' || t.status === 'downloading'
    );
  },

  getCompletedTransfers: () => {
    const { transfers } = get();
    return transfers.filter(t => 
      t.status === 'completed' || t.status === 'failed' || t.status === 'cancelled'
    );
  },
})); 