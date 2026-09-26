import 'dart:io';

import 'package:flutter/material.dart';

import '../models/shared_file.dart';
import '../services/share_api_service.dart';

class ShareProvider extends ChangeNotifier {
  final ShareApiService _service = ShareApiService();

  bool _isUploading = false;
  bool _isLookingUp = false;
  bool _isDownloading = false;
  String? _error;
  SharedFile? _uploadedFile;
  SharedFile? _foundFile;
  DownloadedSharedFile? _downloadedFile;

  bool get isUploading => _isUploading;
  bool get isLookingUp => _isLookingUp;
  bool get isDownloading => _isDownloading;
  String? get error => _error;
  SharedFile? get uploadedFile => _uploadedFile;
  SharedFile? get foundFile => _foundFile;
  DownloadedSharedFile? get downloadedFile => _downloadedFile;

  Future<SharedFile?> uploadFile(File file, {int maxDownloads = 1}) async {
    _isUploading = true;
    _error = null;
    _uploadedFile = null;
    notifyListeners();

    try {
      final sharedFile = await _service.uploadFile(file, maxDownloads: maxDownloads);
      _uploadedFile = sharedFile;
      return sharedFile;
    } on ShareApiException catch (error) {
      _error = error.message;
      return null;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Future<SharedFile?> uploadText(
    String text, {
    String filename = 'swiftshare-note.txt',
    int maxDownloads = 1,
  }) async {
    _isUploading = true;
    _error = null;
    _uploadedFile = null;
    notifyListeners();

    try {
      final sharedFile = await _service.uploadText(
        text,
        filename: filename,
        maxDownloads: maxDownloads,
      );
      _uploadedFile = sharedFile;
      return sharedFile;
    } on ShareApiException catch (error) {
      _error = error.message;
      return null;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Future<SharedFile?> lookupCode(String code) async {
    _isLookingUp = true;
    _error = null;
    _foundFile = null;
    _downloadedFile = null;
    notifyListeners();

    try {
      final sharedFile = await _service.getFileByCode(code);
      _foundFile = sharedFile;
      return sharedFile;
    } on ShareApiException catch (error) {
      _error = error.message;
      return null;
    } finally {
      _isLookingUp = false;
      notifyListeners();
    }
  }

  Future<DownloadedSharedFile?> downloadFoundFile() async {
    final sharedFile = _foundFile;
    if (sharedFile == null) return null;

    _isDownloading = true;
    _error = null;
    _downloadedFile = null;
    notifyListeners();

    try {
      final downloaded = await _service.downloadFile(sharedFile);
      _downloadedFile = downloaded;
      return downloaded;
    } on ShareApiException catch (error) {
      _error = error.message;
      return null;
    } finally {
      _isDownloading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
