export interface FileData {
  id: string;
  code: string;
  filename: string;
  size: number;
  type: string;
  url: string;
  qrUrl: string;
  expiresAt: Date;
  downloadCount: number;
  maxDownloads: number;
  uploadedAt: Date;
  uploadedBy?: string;
  checksum?: string;
  encrypted?: boolean;
  compression?: boolean;
}

export interface UploadProgress {
  loaded: number;
  total: number;
  percentage: number;
}

export interface FileUploadState {
  isUploading: boolean;
  progress: UploadProgress | null;
  error: string | null;
  file: FileData | null;
}