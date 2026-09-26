import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isFirstLaunch = true;
  String _deviceName = '';
  String _deviceId = '';
  
  /// What MaterialApp.themeMode should use: follow the phone, or force
  /// light / dark.
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isFirstLaunch => _isFirstLaunch;
  String get deviceName => _deviceName;
  String get deviceId => _deviceId;

  AppProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString('themeMode');
    if (savedMode != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (m) => m.name == savedMode,
        orElse: () => ThemeMode.system,
      );
    } else if (prefs.getBool('isDarkMode') == true) {
      // Older versions stored a bool that the app never actually applied.
      _themeMode = ThemeMode.dark;
    }
    _isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
    _deviceName = prefs.getString('deviceName') ?? '';
    _deviceId = prefs.getString('deviceId') ?? '';
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode.name);
  }

  Future<void> setDarkMode(bool value) =>
      setThemeMode(value ? ThemeMode.dark : ThemeMode.light);

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