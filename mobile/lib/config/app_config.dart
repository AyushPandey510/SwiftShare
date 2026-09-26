import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  static const String defaultBackendBaseUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'https://swiftshare-e4dh.onrender.com',
  );
  static const String localDevelopmentBackendBaseUrl = 'http://localhost:3001';
  static const String _backendUrlPreferenceKey = 'backendBaseUrl';

  // Backend configuration - will be dynamically set
  static String _backendBaseUrl = defaultBackendBaseUrl;
  static String _websocketUrl = _buildWebSocketUrl(defaultBackendBaseUrl);

  // API endpoints
  static const String apiUpload = '/api/upload';
  static const String apiFile = '/api/file';
  static const String apiTransfer = '/api/transfer';
  static const String apiDevices = '/api/devices';
  static const String apiTransfers = '/api/transfers';
  static const String apiDownload = '/api/download';
  static const String apiQr = '/api/qr';
  static const String apiHealth = '/health';

  // Transfer settings
  static const int maxFileSize = 250 * 1024 * 1024; // 250MB
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
    'jpg',
    'jpeg',
    'png',
    'gif',
    'bmp',
    'webp',
    'mp4',
    'avi',
    'mov',
    'mkv',
    'wmv',
    'flv',
    'mp3',
    'wav',
    'aac',
    'flac',
    'ogg',
    'pdf',
    'doc',
    'docx',
    'xls',
    'xlsx',
    'ppt',
    'pptx',
    'txt',
    'rtf',
    'zip',
    'rar',
    '7z',
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
  static Future<void> loadSavedBackendUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUrl = prefs.getString(_backendUrlPreferenceKey);
    const hasBuildBackend =
        defaultBackendBaseUrl != localDevelopmentBackendBaseUrl;

    if (hasBuildBackend && _isLocalBackendUrl(savedUrl)) {
      await prefs.remove(_backendUrlPreferenceKey);
      return;
    }

    if (savedUrl != null && savedUrl.trim().isNotEmpty) {
      await setBackendUrls(savedUrl, persist: false);
    }
  }

  static Future<void> setBackendUrls(String baseUrl,
      {bool persist = true}) async {
    final normalizedUrl = baseUrl.trim().replaceFirst(RegExp(r'/+$'), '');
    if (normalizedUrl.isEmpty) return;

    _backendBaseUrl = normalizedUrl;
    _websocketUrl = _buildWebSocketUrl(normalizedUrl);

    if (persist) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_backendUrlPreferenceKey, normalizedUrl);
    }
  }

  // Helper methods
  static String getFullUrl(String endpoint) {
    return '$_backendBaseUrl$endpoint';
  }

  static String getWebSocketUrl() {
    return _websocketUrl;
  }

  static bool _isLocalBackendUrl(String? url) {
    if (url == null || url.trim().isEmpty) return false;

    final host = Uri.tryParse(url.trim())?.host.toLowerCase();
    if (host == null || host.isEmpty) return false;

    return host == 'localhost' ||
        host == '127.0.0.1' ||
        host == '10.0.2.2' ||
        host.startsWith('192.168.') ||
        host.startsWith('10.') ||
        RegExp(r'^172\.(1[6-9]|2[0-9]|3[0-1])\.').hasMatch(host);
  }

  static String _buildWebSocketUrl(String baseUrl) {
    final normalizedUrl = baseUrl.trim().replaceFirst(RegExp(r'/+$'), '');
    if (normalizedUrl.startsWith('https://')) {
      return '${normalizedUrl.replaceFirst('https://', 'wss://')}/ws';
    }
    if (normalizedUrl.startsWith('http://')) {
      return '${normalizedUrl.replaceFirst('http://', 'ws://')}/ws';
    }
    return 'ws://$normalizedUrl/ws';
  }

  static bool isFileTypeSupported(String extension) {
    return supportedFileTypes.contains(extension.toLowerCase());
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  static String formatTransferSpeed(double bytesPerSecond) {
    if (bytesPerSecond < 1024) {
      return '${bytesPerSecond.toStringAsFixed(1)} B/s';
    }
    if (bytesPerSecond < 1024 * 1024) {
      return '${(bytesPerSecond / 1024).toStringAsFixed(1)} KB/s';
    }
    return '${(bytesPerSecond / (1024 * 1024)).toStringAsFixed(1)} MB/s';
  }
}
