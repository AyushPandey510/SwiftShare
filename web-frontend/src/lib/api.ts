import { FileData } from '@/types/file';

const DEFAULT_API_PORT = 3001;

const resolveApiBaseUrl = () => {
  const configured = (import.meta.env.VITE_API_BASE_URL as string | undefined)?.trim();
  if (configured) {
    return configured.replace(/\/$/, '');
  }

  if (import.meta.env.DEV && typeof window !== 'undefined' && window.location.hostname) {
    const protocol = window.location.protocol === 'https:' ? 'https:' : 'http:';
    return `${protocol}//${window.location.hostname}:${DEFAULT_API_PORT}`;
  }

  return `http://localhost:${DEFAULT_API_PORT}`;
};

export const API_BASE_URL = resolveApiBaseUrl();

export const getApiBaseUrl = () => API_BASE_URL;

export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: string;
}

// File upload API
export const uploadFile = async (
  file: File,
  maxDownloads = 1,
): Promise<ApiResponse<FileData>> => {
  try {
    const formData = new FormData();
    formData.append('maxDownloads', String(Math.min(Math.max(maxDownloads, 1), 10)));
    formData.append('file', file);

    const response = await fetch(`${API_BASE_URL}/api/upload`, {
      method: 'POST',
      body: formData,
    });

    if (!response.ok) {
      let message = `HTTP error! status: ${response.status}`;
      try {
        const body = await response.json();
        if (body?.error) message = body.error;
      } catch {
        // ignore unparseable error bodies
      }
      throw new Error(message);
    }

    const result = await response.json();
    return {
      success: Boolean(result.success),
      data: result.data ?? result.file,
      error: result.error,
    };
  } catch (error) {
    console.error('Upload error:', error);
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Upload failed'
    };
  }
};

// Get file by code
export const getFileByCode = async (code: string): Promise<ApiResponse<FileData>> => {
  try {
    const response = await fetch(`${API_BASE_URL}/api/file/${code}`);

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const result = await response.json();
    return result;
  } catch (error) {
    console.error('Get file error:', error);
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to get file'
    };
  }
};

// Download file
export const downloadFile = async (code: string): Promise<Blob | null> => {
  try {
    const response = await fetch(`${API_BASE_URL}/api/download/${code}`);

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    return await response.blob();
  } catch (error) {
    console.error('Download error:', error);
    return null;
  }
};

// Get QR code
export const getQRCode = async (code: string): Promise<string | null> => {
  try {
    const response = await fetch(`${API_BASE_URL}/api/qr/${code}`);

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const blob = await response.blob();
    return URL.createObjectURL(blob);
  } catch (error) {
    console.error('QR code error:', error);
    return null;
  }
};

// Check backend health
export const checkBackendHealth = async (): Promise<boolean> => {
  try {
    const response = await fetch(`${API_BASE_URL}/health`);
    return response.ok;
  } catch (error) {
    console.error('Health check error:', error);
    return false;
  }
};
