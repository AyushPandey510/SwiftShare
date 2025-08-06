import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _isFirstLaunch = true;
  String _deviceName = '';
  String _deviceId = '';
  
  bool get isDarkMode => _isDarkMode;
  bool get isFirstLaunch => _isFirstLaunch;
  String get deviceName => _deviceName;
  String get deviceId => _deviceId;

  AppProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
    _deviceName = prefs.getString('deviceName') ?? '';
    _deviceId = prefs.getString('deviceId') ?? '';
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    notifyListeners();
  }

  Future<void> setFirstLaunch(bool value) async {
    _isFirstLaunch = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstLaunch', value);
    notifyListeners();
  }

  Future<void> setDeviceName(String name) async {
    _deviceName = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('deviceName', name);
    notifyListeners();
  }

  Future<void> setDeviceId(String id) async {
    _deviceId = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('deviceId', id);
    notifyListeners();
  }
} 