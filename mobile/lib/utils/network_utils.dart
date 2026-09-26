import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:network_info_plus/network_info_plus.dart';
import '../config/app_config.dart';

class NetworkUtils {
  static final NetworkInfo _networkInfo = NetworkInfo();

  /// Get the local IP address of the device
  static Future<String?> getLocalIpAddress() async {
    try {
      return await _networkInfo.getWifiIP();
    } catch (e) {
      debugPrint('Error getting local IP: $e');
      return null;
    }
  }

  /// Get the gateway IP address (usually the router)
  static Future<String?> getGatewayIpAddress() async {
    try {
      return await _networkInfo.getWifiGatewayIP();
    } catch (e) {
      debugPrint('Error getting gateway IP: $e');
      return null;
    }
  }

  /// Automatically detect and configure the backend server
  static Future<bool> autoConfigureBackend() async {
    debugPrint('Starting automatic backend configuration...');
    final originalUrl = AppConfig.backendBaseUrl;

    // First, try the current configuration
    if (await testBackendConnection()) {
      debugPrint('Current backend configuration is working');
      return true;
    }

    // Try to detect the backend server
    final detectedUrl = await detectBackendServer();
    if (detectedUrl != null) {
      debugPrint('Backend detected at: $detectedUrl');
      await AppConfig.setBackendUrls(detectedUrl, persist: false);

      // Test the new configuration
      if (await testBackendConnection()) {
        await AppConfig.setBackendUrls(detectedUrl);
        debugPrint('Backend configuration successful');
        return true;
      }
    }

    // Try common network configurations
    final commonUrls = getPotentialBackendUrls();
    for (final url in commonUrls) {
      debugPrint('Trying common URL: $url');
      await AppConfig.setBackendUrls(url, persist: false);

      if (await testBackendConnection()) {
        await AppConfig.setBackendUrls(url);
        debugPrint('Backend found at common URL: $url');
        return true;
      }
    }

    debugPrint('No backend server found');
    await AppConfig.setBackendUrls(originalUrl, persist: false);
    return false;
  }

  /// Detect the backend server IP by scanning common network ranges
  static Future<String?> detectBackendServer() async {
    final localIp = await getLocalIpAddress();
    if (localIp == null) return null;

    debugPrint('Local IP: $localIp');

    // Parse the local IP to get the network prefix
    final parts = localIp.split('.');
    if (parts.length != 4) return null;

    final networkPrefix = '${parts[0]}.${parts[1]}.${parts[2]}';
    debugPrint('Scanning network: $networkPrefix.x');

    // Common ports to check
    const ports = [3001, 8080, 3000, 8000, 5000];

    // Start with common device IPs first
    final commonDeviceIps = [1, 100, 101, 102, 103, 104, 105, 254];

    // Try common device IPs first for faster detection
    for (final i in commonDeviceIps) {
      final testIp = '$networkPrefix.$i';

      for (final port in ports) {
        debugPrint('Testing $testIp:$port');
        if (await _isBackendServer(testIp, port)) {
          debugPrint('Backend found at $testIp:$port');
          return 'http://$testIp:$port';
        }
      }
    }

    // If not found in common IPs, scan the full range
    for (int i = 1; i <= 254; i++) {
      // Skip common IPs we already checked
      if (commonDeviceIps.contains(i)) continue;

      final testIp = '$networkPrefix.$i';

      for (final port in ports) {
        if (await _isBackendServer(testIp, port)) {
          debugPrint('Backend found at $testIp:$port');
          return 'http://$testIp:$port';
        }
      }
    }

    return null;
  }

  /// Check if a specific IP and port is running the backend server
  static Future<bool> _isBackendServer(String ip, int port) async {
    try {
      final response = await http
          .get(Uri.parse('http://$ip:$port${AppConfig.apiHealth}'))
          .timeout(const Duration(seconds: 1));
      return response.statusCode >= 200 && response.statusCode < 500;
    } catch (e) {
      return false;
    }
  }

  /// Test connection to the configured backend
  static Future<bool> testBackendConnection() async {
    try {
      final response = await http
          .get(Uri.parse('${AppConfig.backendBaseUrl}${AppConfig.apiHealth}'))
          .timeout(const Duration(seconds: 3));
      return response.statusCode >= 200 && response.statusCode < 500;
    } catch (e) {
      debugPrint('Backend connection test failed: $e');
      return false;
    }
  }

  /// Get network information for debugging
  static Future<Map<String, String?>> getNetworkInfo() async {
    return {
      'localIp': await getLocalIpAddress(),
      'gatewayIp': await getGatewayIpAddress(),
      'backendUrl': AppConfig.backendBaseUrl,
      'isConnected': (await testBackendConnection()).toString(),
    };
  }

  /// Generate a list of potential backend URLs based on common network configurations
  static List<String> getPotentialBackendUrls() {
    return [
      'http://localhost:3001',
      'http://10.0.2.2:3001',
      'http://127.0.0.1:3001',
      'http://192.168.1.100:3001',
      'http://192.168.0.100:3001',
      'http://192.168.1.1:3001',
      'http://192.168.0.1:3001',
      'http://10.0.0.100:3001',
      'http://10.0.0.1:3001',
      'http://192.168.1.100:8080',
      'http://192.168.0.100:8080',
      'http://192.168.1.1:8080',
      'http://192.168.0.1:8080',
      'http://10.0.0.100:8080',
      'http://10.0.0.1:8080',
      'http://172.16.0.100:8080',
      'http://172.16.0.1:8080',
    ];
  }

  /// Get the current backend status
  static Future<Map<String, dynamic>> getBackendStatus() async {
    final isConnected = await testBackendConnection();
    final networkInfo = await getNetworkInfo();

    return {
      'isConnected': isConnected,
      'backendUrl': AppConfig.backendBaseUrl,
      'networkInfo': networkInfo,
    };
  }
}
