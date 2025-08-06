// Shared types for SwiftShare applications

export interface Device {
  id: string;
  name: string;
  type: 'mobile' | 'desktop' | 'web';
  ip: string;
  port: number;
  lastSeen: Date;
  isOnline: boolean;
  capabilities: Capability[];
  transferSpeed?: number; // MB/s
}

export interface Transfer {
  id: string;
  files: TransferFile[];
  targetDevice: Device;
  status: TransferStatus;
  progress: number;
  startTime: Date;
  endTime?: Date;
  speed: number; // MB/s
  error?: string;
}

export interface TransferFile {
  id: string;
  name: string;
  size: number;
  type: FileType;
  path?: string;
  checksum?: string;
  progress?: number;
}

export type TransferStatus = 
  | 'pending'
  | 'in-progress'
  | 'completed'
  | 'failed'
  | 'cancelled'
  | 'paused';

export type FileType = 
  | 'image'
  | 'video'
  | 'audio'
  | 'document'
  | 'archive'
  | 'other';

export type Capability = 
  | 'file-transfer'
  | 'encryption'
  | 'compression'
  | 'group-sharing'
  | 'resume-transfer';

export interface TransferRequest {
  id: string;
  files: TransferFile[];
  targetDevice: Device;
  encrypted: boolean;
  compressed: boolean;
}

export interface TransferResponse {
  id: string;
  status: TransferStatus;
  message: string;
  progress?: number;
  speed?: number;
}

export interface NetworkConfig {
  localIp: string;
  port: number;
  discoveryEnabled: boolean;
  autoScan: boolean;
  scanInterval: number;
}

export interface AppSettings {
  downloadPath: string;
  enableEncryption: boolean;
  autoCompress: boolean;
  notifications: boolean;
  autoScan: boolean;
  maxFileSize: number;
  bufferSize: number;
  theme: 'light' | 'dark' | 'system';
  language: string;
}

export interface TransferStats {
  totalTransfers: number;
  successfulTransfers: number;
  failedTransfers: number;
  totalBytesTransferred: number;
  averageSpeed: number;
  lastTransferDate?: Date;
}

// API Response types
export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
}

export interface DevicesResponse {
  devices: Device[];
  count: number;
  timestamp: string;
}

export interface HealthResponse {
  status: 'healthy' | 'unhealthy';
  timestamp: string;
  version: string;
  uptime: number;
}

// Event types for WebSocket communication
export interface TransferEvent {
  type: 'transfer-started' | 'transfer-progress' | 'transfer-completed' | 'transfer-failed';
  transferId: string;
  data: any;
}

export interface DeviceEvent {
  type: 'device-found' | 'device-lost' | 'device-updated';
  device: Device;
}

export interface NetworkEvent {
  type: 'network-changed' | 'scan-started' | 'scan-completed';
  data: any;
}

// Utility types
export type FileSize = {
  bytes: number;
  formatted: string;
};

export type TransferSpeed = {
  bytesPerSecond: number;
  formatted: string;
};

// Constants
export const SUPPORTED_FILE_TYPES = {
  images: ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp', '.svg'],
  videos: ['.mp4', '.avi', '.mov', '.mkv', '.wmv', '.flv', '.webm'],
  audio: ['.mp3', '.wav', '.flac', '.aac', '.ogg', '.m4a'],
  documents: ['.pdf', '.doc', '.docx', '.txt', '.rtf', '.odt'],
  archives: ['.zip', '.rar', '.7z', '.tar', '.gz'],
} as const;

export const DEFAULT_SETTINGS: AppSettings = {
  downloadPath: '',
  enableEncryption: true,
  autoCompress: false,
  notifications: true,
  autoScan: true,
  maxFileSize: 1024 * 1024 * 1024, // 1GB
  bufferSize: 8192, // 8KB
  theme: 'system',
  language: 'en',
};

export const DEFAULT_NETWORK_CONFIG: NetworkConfig = {
  localIp: '',
  port: 8080,
  discoveryEnabled: true,
  autoScan: true,
  scanInterval: 30000, // 30 seconds
}; 