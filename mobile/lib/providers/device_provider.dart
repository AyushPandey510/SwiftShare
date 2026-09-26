import 'package:flutter/foundation.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'dart:io';
import '../services/file_transfer_service.dart';

class Device {
  final String id;
  final String name;
  final String address;
  final DeviceType type;
  final List<String> capabilities;
  final DateTime lastSeen;
  final bool isOnline;

  Device({
    required this.id,
    required this.name,
    required this.address,
    required this.type,
    required this.capabilities,
    required this.lastSeen,
    this.isOnline = true,
  });
}

enum DeviceType {
  mobile,
  desktop,
  web,
}

class DeviceProvider extends ChangeNotifier {
  List<Device> _devices = [];
  bool _isScanning = false;
  String _localIpAddress = '';
  String? _discoveryError;
  final FileTransferService _fileTransferService = FileTransferService();

  List<Device> get devices => _devices;
  bool get isScanning => _isScanning;
  String get localIpAddress => _localIpAddress;
  String? get discoveryError => _discoveryError;

  List<Device> get onlineDevices => 
      _devices.where((d) => d.isOnline).toList();

  DeviceProvider() {
    _initializeLocalInfo();
    _startDeviceDiscovery();
  }

  Future<void> _initializeLocalInfo() async {
    try {
      final networkInfo = NetworkInfo();
      
      // Platform-specific IP detection
      if (kIsWeb) {
        // Web platform - use a fallback or mock IP
        _localIpAddress = '127.0.0.1';
        debugPrint('Running on web platform - using fallback IP');
      } else if (Platform.isAndroid || Platform.isIOS) {
        // Mobile platforms
        _localIpAddress = await networkInfo.getWifiIP() ?? '127.0.0.1';
      } else {
        // Desktop platforms
        _localIpAddress = await networkInfo.getWifiIP() ?? '127.0.0.1';
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error getting local IP: $e');
      _localIpAddress = '127.0.0.1';
      notifyListeners();
    }
  }

  Future<void> _startDeviceDiscovery() async {
    _isScanning = true;
    notifyListeners();

    try {
      // Initialize file transfer service
      await _fileTransferService.initialize();
      
      // Get real devices from backend
      final devicesData = await _fileTransferService.getAvailableDevices();
      _devices = devicesData.map(_deviceFromJson).toList();
      _discoveryError = null;
      
    } catch (e) {
      debugPrint('Error discovering devices: $e');
      _devices = [];
      _discoveryError = 'Could not load nearby devices. Check that the backend is running and reachable.';
    }

    _isScanning = false;
    notifyListeners();
  }

  Future<void> refreshDevices() async {
    _isScanning = true;
    notifyListeners();

    try {
      // Get real devices from backend
      final devicesData = await _fileTransferService.getAvailableDevices();
      _devices = devicesData.map(_deviceFromJson).toList();
      _discoveryError = null;
      
    } catch (e) {
      debugPrint('Error refreshing devices: $e');
      _discoveryError = 'Could not refresh nearby devices. Check your backend connection.';
    }

    _isScanning = false;
    notifyListeners();
  }

  void addDevice(Device device) {
    final existingIndex = _devices.indexWhere((d) => d.id == device.id);
    if (existingIndex != -1) {
      _devices[existingIndex] = device;
    } else {
      _devices.add(device);
    }
    notifyListeners();
  }

  void removeDevice(String deviceId) {
    _devices.removeWhere((d) => d.id == deviceId);
    notifyListeners();
  }

  void updateDeviceStatus(String deviceId, bool isOnline) {
    final index = _devices.indexWhere((d) => d.id == deviceId);
    if (index != -1) {
      final device = _devices[index];
      _devices[index] = Device(
        id: device.id,
        name: device.name,
        address: device.address,
        type: device.type,
        capabilities: device.capabilities,
        lastSeen: DateTime.now(),
        isOnline: isOnline,
      );
      notifyListeners();
    }
  }

  Device? getDevice(String deviceId) {
    try {
      return _devices.firstWhere((d) => d.id == deviceId);
    } catch (e) {
      return null;
    }
  }

  List<Device> getDevicesByType(DeviceType type) {
    return _devices.where((d) => d.type == type).toList();
  }

  String getDeviceTypeIcon(DeviceType type) {
    switch (type) {
      case DeviceType.mobile:
        return '📱';
      case DeviceType.desktop:
        return '💻';
      case DeviceType.web:
        return '🌐';
    }
  }

  String getDeviceTypeName(DeviceType type) {
    switch (type) {
      case DeviceType.mobile:
        return 'Mobile';
      case DeviceType.desktop:
        return 'Desktop';
      case DeviceType.web:
        return 'Web';
    }
  }

  String formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  DeviceType _parseDeviceType(String type) {
    switch (type.toLowerCase()) {
      case 'mobile':
        return DeviceType.mobile;
      case 'desktop':
        return DeviceType.desktop;
      case 'web':
        return DeviceType.web;
      default:
        return DeviceType.mobile;
    }
  }

  Device _deviceFromJson(Map<String, dynamic> deviceData) {
    final ip = deviceData['ip']?.toString();
    final apiPort = deviceData['api_port'] ?? deviceData['apiPort'] ?? deviceData['port'];
    final fallbackAddress = deviceData['address']?.toString() ?? '';
    final address = ip == null || ip.isEmpty
        ? fallbackAddress
        : apiPort == null
            ? ip
            : '$ip:$apiPort';

    return Device(
      id: deviceData['id']?.toString() ?? '',
      name: deviceData['name']?.toString() ?? 'Unknown Device',
      address: address,
      type: _parseDeviceType(
        (deviceData['device_type'] ?? deviceData['deviceType'] ?? deviceData['type'] ?? '')
            .toString(),
      ),
      capabilities: List<String>.from(deviceData['capabilities'] is List ? deviceData['capabilities'] : const []),
      lastSeen: DateTime.tryParse(deviceData['last_seen']?.toString() ?? '') ?? DateTime.now(),
      isOnline: (deviceData['is_online'] ?? deviceData['isOnline']) != false,
    );
  }
} 
