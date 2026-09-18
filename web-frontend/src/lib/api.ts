import { FileData } from '@/types/file';
import { formatFileSize, MAX_UPLOAD_BYTES } from '@/lib/site';

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
      return {
        success: false,
        error: response.status === 413
          ? `This upload is too large. Choose a file under ${formatFileSize(MAX_UPLOAD_BYTES)} and try again.`
          : response.status === 429
            ? 'There have been too many upload attempts. Wait a moment and try again.'
            : 'Your file could not be uploaded. Please try again in a moment.',
      };
    }

    const result = await response.json();
    return {
      success: Boolean(result.success),
      data: result.data ?? result.file,
      error: result.success ? undefined : 'Your file could not be uploaded. Please try again.',
    };
  } catch (error) {
    console.error('Upload error:', error);
    return {
      success: false,
      error: 'We could not complete your upload. Check your connection and try again.'
    };
  }
};

// Get file by code
export const getFileByCode = async (code: string): Promise<ApiResponse<FileData>> => {
  try {
    const response = await fetch(`${API_BASE_URL}/api/file/${code}`);

    if (!response.ok) {
      return {
        success: false,
        error: response.status === 404
          ? 'We could not find that file. Check the code or ask the sender for a new link.'
          : response.status === 410
            ? 'This file is no longer available. Ask the sender to share it again.'
            : 'We could not look up your file. Please try again in a moment.',
      };
    }

    const result = await response.json();
    if (!result.success) {
      return {
        success: false,
        error: result.error === 'File expired'
          ? 'This link has expired. Ask the sender to share the file again.'
          : 'We could not find that file. Check the code or ask the sender for a new link.',
      };
    }
    return result;
  } catch (error) {
    console.error('Get file error:', error);
    return {
      success: false,
      error: 'We could not look up your file. Check your connection and try again.'
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
