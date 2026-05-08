class AppConfig {
  // Backend configuration - will be dynamically set
  static String _backendBaseUrl = 'http://192.168.1.100:8080';
  static String _websocketUrl = 'ws://192.168.1.100:8080/ws';
  
  // API endpoints
  static const String apiTransfer = '/api/transfer';
  static const String apiDevices = '/api/devices';
  static const String apiTransfers = '/api/transfers';
  static const String apiDownload = '/api/download';
  
  // Transfer settings
  static const int maxFileSize = 100 * 1024 * 1024; // 100MB
  static const int chunkSize = 8192; // 8KB chunks
  static const Duration transferTimeout = Duration(minutes: 30);
  
  // Discovery settings
  static const Duration deviceScanInterval = Duration(seconds: 30);
  static const Duration deviceTimeout = Duration(seconds: 5);
  
  // UI settings
  static const Duration progressUpdateInterval = Duration(milliseconds: 100);
  static const Duration animationDuration = Duration(milliseconds: 300);
  
  // File settings
  static const List<String> supportedFileTypes = [
    'jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp',
    'mp4', 'avi', 'mov', 'mkv', 'wmv', 'flv',
    'mp3', 'wav', 'aac', 'flac', 'ogg',
    'pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx',
    'txt', 'rtf', 'zip', 'rar', '7z',
  ];
  
  static const int maxFileNameLength = 255;
  
  // Error messages
  static const String errorNetworkUnavailable = 'Network is not available';
  static const String errorFileTooLarge = 'File is too large';
  static const String errorTransferFailed = 'File transfer failed';
  static const String errorDeviceNotFound = 'Device not found';
  static const String errorPermissionDenied = 'Permission denied';
  
  // Success messages
  static const String successTransferCompleted = 'File transfer completed';
  static const String successFileSaved = 'File saved successfully';
  
  // Getters for backend URLs
  static String get backendBaseUrl => _backendBaseUrl;
  static String get websocketUrl => _websocketUrl;
  
  // Setter for backend URLs
  static void setBackendUrls(String baseUrl) {
    _backendBaseUrl = baseUrl;
    _websocketUrl = '${baseUrl.replaceFirst('http://', 'ws://')}/ws';
  }
  
  // Helper methods
  static String getFullUrl(String endpoint) {
    return '$_backendBaseUrl$endpoint';
  }
  
  static String getWebSocketUrl() {
    return _websocketUrl;
  }
  
  static bool isFileTypeSupported(String extension) {
    return supportedFileTypes.contains(extension.toLowerCase());
  }
  
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  
  static String formatTransferSpeed(double bytesPerSecond) {
    if (bytesPerSecond < 1024) return '${bytesPerSecond.toStringAsFixed(1)} B/s';
    if (bytesPerSecond < 1024 * 1024) return '${(bytesPerSecond / 1024).toStringAsFixed(1)} KB/s';
    return '${(bytesPerSecond / (1024 * 1024)).toStringAsFixed(1)} MB/s';
  }
} 