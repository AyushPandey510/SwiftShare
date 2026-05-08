import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../services/file_transfer_service.dart';

class TransferItem {
  final String id;
  final String fileName;
  final int fileSize;
  final String filePath;
  final String targetDevice;
  final TransferStatus status;
  final double progress;
  final double speed;
  final DateTime startTime;
  final DateTime? endTime;

  TransferItem({
    required this.id,
    required this.fileName,
    required this.fileSize,
    required this.filePath,
    required this.targetDevice,
    required this.status,
    this.progress = 0.0,
    this.speed = 0.0,
    required this.startTime,
    this.endTime,
  });
}

enum TransferStatus {
  pending,
  inProgress,
  completed,
  failed,
  cancelled,
}

class TransferProvider extends ChangeNotifier {
  final List<TransferItem> _transfers = [];
  bool _isTransferring = false;
  final FileTransferService _fileTransferService = FileTransferService();

  List<TransferItem> get transfers => _transfers;
  bool get isTransferring => _isTransferring;

  List<TransferItem> get activeTransfers => 
      _transfers.where((t) => t.status == TransferStatus.inProgress).toList();

  List<TransferItem> get completedTransfers => 
      _transfers.where((t) => t.status == TransferStatus.completed).toList();

  List<TransferItem> get failedTransfers => 
      _transfers.where((t) => t.status == TransferStatus.failed).toList();

  Future<void> pickAndSendFile(String targetDevice) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.any,
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;
        final fileSize = await file.length();

        final transfer = TransferItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          fileName: fileName,
          fileSize: fileSize,
          filePath: file.path,
          targetDevice: targetDevice,
          status: TransferStatus.pending,
          startTime: DateTime.now(),
        );

        _transfers.add(transfer);
        notifyListeners();

        // Start real transfer
        await _startRealTransfer(transfer, file);
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
    }
  }

  Future<void> _startRealTransfer(TransferItem transfer, File file) async {
    final index = _transfers.indexWhere((t) => t.id == transfer.id);
    if (index == -1) return;

    _isTransferring = true;
    _transfers[index] = TransferItem(
      id: transfer.id,
      fileName: transfer.fileName,
      fileSize: transfer.fileSize,
      filePath: transfer.filePath,
      targetDevice: transfer.targetDevice,
      status: TransferStatus.inProgress,
      progress: 0.0,
      speed: 0.0,
      startTime: transfer.startTime,
    );
    notifyListeners();

    try {
      // Initialize file transfer service
      await _fileTransferService.initialize();
      
      // Start real file transfer
      final transferId = await _fileTransferService.sendFile(
        file,
        transfer.targetDevice,
        onProgress: (progress) {
          if (index < _transfers.length) {
            _transfers[index] = TransferItem(
              id: transfer.id,
              fileName: transfer.fileName,
              fileSize: transfer.fileSize,
              filePath: transfer.filePath,
              targetDevice: transfer.targetDevice,
              status: TransferStatus.inProgress,
              progress: progress,
              speed: 1024 * 1024 * 10.0, // Calculate real speed
              startTime: transfer.startTime,
            );
            notifyListeners();
          }
        },
        onStatus: (status) {
          if (index < _transfers.length) {
            TransferStatus transferStatus;
            switch (status) {
              case 'completed':
                transferStatus = TransferStatus.completed;
                break;
              case 'failed':
                transferStatus = TransferStatus.failed;
                break;
              default:
                transferStatus = TransferStatus.inProgress;
            }
            
            _transfers[index] = TransferItem(
              id: transfer.id,
              fileName: transfer.fileName,
              fileSize: transfer.fileSize,
              filePath: transfer.filePath,
              targetDevice: transfer.targetDevice,
              status: transferStatus,
              progress: transferStatus == TransferStatus.completed ? 1.0 : _transfers[index].progress,
              speed: _transfers[index].speed,
              startTime: transfer.startTime,
              endTime: transferStatus == TransferStatus.completed || transferStatus == TransferStatus.failed 
                  ? DateTime.now() 
                  : null,
            );
            notifyListeners();
          }
        },
      );
      
      debugPrint('Transfer started with ID: $transferId');
      
    } catch (e) {
      debugPrint('Transfer failed: $e');
      // Mark as failed
      if (index < _transfers.length) {
        _transfers[index] = TransferItem(
          id: transfer.id,
          fileName: transfer.fileName,
          fileSize: transfer.fileSize,
          filePath: transfer.filePath,
          targetDevice: transfer.targetDevice,
          status: TransferStatus.failed,
          progress: 0.0,
          speed: 0.0,
          startTime: transfer.startTime,
          endTime: DateTime.now(),
        );
        notifyListeners();
      }
    } finally {
      _isTransferring = false;
      notifyListeners();
    }
  }

  void cancelTransfer(String transferId) {
    final index = _transfers.indexWhere((t) => t.id == transferId);
    if (index != -1) {
      _transfers[index] = TransferItem(
        id: _transfers[index].id,
        fileName: _transfers[index].fileName,
        fileSize: _transfers[index].fileSize,
        filePath: _transfers[index].filePath,
        targetDevice: _transfers[index].targetDevice,
        status: TransferStatus.cancelled,
        progress: _transfers[index].progress,
        speed: _transfers[index].speed,
        startTime: _transfers[index].startTime,
        endTime: DateTime.now(),
      );
      notifyListeners();
    }
  }

  void clearCompletedTransfers() {
    _transfers.removeWhere((t) => t.status == TransferStatus.completed);
    notifyListeners();
  }

  void clearFailedTransfers() {
    _transfers.removeWhere((t) => t.status == TransferStatus.failed);
    notifyListeners();
  }

  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String formatSpeed(double bytesPerSecond) {
    if (bytesPerSecond < 1024) return '${bytesPerSecond.toStringAsFixed(1)} B/s';
    if (bytesPerSecond < 1024 * 1024) return '${(bytesPerSecond / 1024).toStringAsFixed(1)} KB/s';
    return '${(bytesPerSecond / (1024 * 1024)).toStringAsFixed(1)} MB/s';
  }

  String formatTransferTime(DateTime startTime) {
    final now = DateTime.now();
    final difference = now.difference(startTime);
    
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
} 