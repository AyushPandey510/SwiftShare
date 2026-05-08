import 'dart:io';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import '../config/app_config.dart';

class FileTransferService {
  static  final String _baseUrl = AppConfig.backendBaseUrl;
  static  final String _wsUrl = AppConfig.websocketUrl;
  
  WebSocketChannel? _channel;
  final Map<String, Function(double)> _progressCallbacks = {};
  final Map<String, Function(String)> _statusCallbacks = {};
  
  // Singleton pattern
  static final FileTransferService _instance = FileTransferService._internal();
  factory FileTransferService() => _instance;
  FileTransferService._internal();

  Future<void> initialize() async {
    // Request storage permissions
    await Permission.storage.request();
    await Permission.manageExternalStorage.request();
    
    // Connect to WebSocket for real-time updates
    await _connectWebSocket();
  }

  Future<void> _connectWebSocket() async {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(_wsUrl));
      
      _channel!.stream.listen(
        (data) {
          _handleWebSocketMessage(data);
        },
        onError: (error) {
          print('WebSocket error: $error');
          _reconnectWebSocket();
        },
        onDone: () {
          print('WebSocket connection closed');
          _reconnectWebSocket();
        },
      );
    } catch (e) {
      print('Failed to connect WebSocket: $e');
    }
  }

  void _reconnectWebSocket() {
    Future.delayed(const Duration(seconds: 5), () {
      _connectWebSocket();
    });
  }

  void _handleWebSocketMessage(dynamic data) {
    try {
      final message = jsonDecode(data);
      final type = message['type'];
      final transferId = message['transferId'];
      
      switch (type) {
        case 'progress':
          final progress = message['progress'] as double;
          _progressCallbacks[transferId]?.call(progress);
          break;
        case 'status':
          final status = message['status'] as String;
          _statusCallbacks[transferId]?.call(status);
          break;
        case 'transfer_complete':
          _statusCallbacks[transferId]?.call('completed');
          break;
        case 'transfer_failed':
          _statusCallbacks[transferId]?.call('failed');
          break;
      }
    } catch (e) {
      print('Error parsing WebSocket message: $e');
    }
  }

  Future<String> sendFile(File file, String targetDeviceId, {
    Function(double)? onProgress,
    Function(String)? onStatus,
  }) async {
    final transferId = const Uuid().v4();
    
    if (onProgress != null) {
      _progressCallbacks[transferId] = onProgress;
    }
    if (onStatus != null) {
      _statusCallbacks[transferId] = onStatus;
    }

    try {
      // Get file info
      final fileSize = await file.length();
      final fileName = file.path.split('/').last;
      
      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl${AppConfig.apiTransfer}'),
      );
      
      // Add file
      final fileStream = http.ByteStream(file.openRead());
      final length = await file.length();
      
      final multipartFile = http.MultipartFile(
        'file',
        fileStream,
        length,
        filename: fileName,
      );
      
      request.files.add(multipartFile);
      
      // Add metadata
      request.fields['transferId'] = transferId;
      request.fields['targetDeviceId'] = targetDeviceId;
      request.fields['fileName'] = fileName;
      request.fields['fileSize'] = fileSize.toString();
      
      // Send request
      final response = await request.send();
      
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final responseJson = jsonDecode(responseData);
        
        if (responseJson['success'] == true) {
          return transferId;
        } else {
          throw Exception(responseJson['error'] ?? 'Transfer failed');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending file: $e');
      rethrow;
    }
  }

  Future<void> receiveFile(String transferId, {
    Function(double)? onProgress,
    Function(String)? onStatus,
  }) async {
    if (onProgress != null) {
      _progressCallbacks[transferId] = onProgress;
    }
    if (onStatus != null) {
      _statusCallbacks[transferId] = onStatus;
    }

    try {
      // Get download directory
      final directory = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory('${directory.path}/SwiftShare/Downloads');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      // Start download
      final response = await http.get(
        Uri.parse('$_baseUrl${AppConfig.apiDownload}/$transferId'),
      );

      if (response.statusCode == 200) {
        // Parse response headers for file info
        final contentDisposition = response.headers['content-disposition'];
        String fileName = 'received_file';
        if (contentDisposition != null) {
          final filenameMatch = RegExp(r'filename="([^"]+)"').firstMatch(contentDisposition);
          if (filenameMatch != null) {
            fileName = filenameMatch.group(1)!;
          }
        }

        final file = File('${downloadsDir.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);
        
        onStatus?.call('completed');
      } else {
        throw Exception('Download failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error receiving file: $e');
      onStatus?.call('failed');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getTransferHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl${AppConfig.apiTransfers}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['transfers'] ?? []);
      } else {
        throw Exception('Failed to get transfer history');
      }
    } catch (e) {
      print('Error getting transfer history: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getTransferStatus(String transferId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl${AppConfig.apiTransfer}/$transferId'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting transfer status: $e');
      return null;
    }
  }

  Future<void> cancelTransfer(String transferId) async {
    try {
      await http.delete(
        Uri.parse('$_baseUrl${AppConfig.apiTransfer}/$transferId'),
      );
    } catch (e) {
      print('Error canceling transfer: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAvailableDevices() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl${AppConfig.apiDevices}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['devices'] ?? []);
      } else {
        throw Exception('Failed to get devices');
      }
    } catch (e) {
      print('Error getting devices: $e');
      return [];
    }
  }

  void dispose() {
    _channel?.sink.close();
    _progressCallbacks.clear();
    _statusCallbacks.clear();
  }
} 