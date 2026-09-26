import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../config/app_config.dart';
import '../models/shared_file.dart';

class ShareApiException implements Exception {
  final String message;

  const ShareApiException(this.message);

  @override
  String toString() => message;
}

class DownloadedSharedFile {
  final File file;
  final String filename;

  const DownloadedSharedFile({
    required this.file,
    required this.filename,
  });
}

class ShareApiService {
  Future<SharedFile> uploadFile(File file, {int maxDownloads = 1}) async {
    final size = await file.length();
    if (size > AppConfig.maxFileSize) {
      throw ShareApiException(
        'This file is too large. Choose a file under ${AppConfig.formatFileSize(AppConfig.maxFileSize)}.',
      );
    }

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(AppConfig.getFullUrl(AppConfig.apiUpload)),
      );

      request.fields['maxDownloads'] = maxDownloads.clamp(1, 10).toString();
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode == 413) {
        throw ShareApiException(
          'This file is too large. Choose a file under ${AppConfig.formatFileSize(AppConfig.maxFileSize)}.',
        );
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw const ShareApiException('Upload failed. Check your connection and try again.');
      }

      final payload = _decodeJson(body);
      if (payload['success'] != true) {
        throw ShareApiException(payload['error']?.toString() ?? 'Upload failed.');
      }

      final data = payload['data'] ?? payload['file'];
      if (data is! Map<String, dynamic>) {
        throw const ShareApiException('Upload response was invalid.');
      }

      return SharedFile.fromJson(data);
    } on ShareApiException {
      rethrow;
    } catch (_) {
      throw const ShareApiException('Backend unavailable. Check your connection and backend URL.');
    }
  }

  Future<SharedFile> uploadText(
    String text, {
    String filename = 'swiftshare-note.txt',
    int maxDownloads = 1,
  }) async {
    if (text.trim().isEmpty) {
      throw const ShareApiException('Paste some text before creating a share link.');
    }

    final tempDir = await getTemporaryDirectory();
    final safeName = _sanitizeFilename(filename.trim().isEmpty ? 'swiftshare-note.txt' : filename);
    final file = File('${tempDir.path}/$safeName');
    await file.writeAsString(text);
    return uploadFile(file, maxDownloads: maxDownloads);
  }

  Future<SharedFile> getFileByCode(String code) async {
    final normalizedCode = normalizeCode(code);
    if (normalizedCode == null) {
      throw const ShareApiException('Enter a valid six-character code.');
    }

    try {
      final response = await http.get(
        Uri.parse('${AppConfig.getFullUrl(AppConfig.apiFile)}/$normalizedCode'),
      );

      if (response.statusCode == 404) {
        throw const ShareApiException('No file was found for that code.');
      }
      if (response.statusCode == 410) {
        throw const ShareApiException('This file is no longer available.');
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw const ShareApiException('Could not look up that file.');
      }

      final payload = _decodeJson(response.body);
      if (payload['success'] != true) {
        final error = payload['error']?.toString();
        if (error == 'File expired') {
          throw const ShareApiException('This file has expired.');
        }
        throw const ShareApiException('No file was found for that code.');
      }

      final data = payload['data'];
      if (data is! Map<String, dynamic>) {
        throw const ShareApiException('File lookup response was invalid.');
      }

      return SharedFile.fromJson(data);
    } on ShareApiException {
      rethrow;
    } catch (_) {
      throw const ShareApiException('Backend unavailable. Check your connection and backend URL.');
    }
  }

  Future<DownloadedSharedFile> downloadFile(SharedFile sharedFile) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.getFullUrl(AppConfig.apiDownload)}/${sharedFile.code}'),
      );

      if (response.statusCode == 404) {
        throw const ShareApiException('No file was found for that code.');
      }
      if (response.statusCode == 410) {
        throw const ShareApiException('This file is expired or has reached its download limit.');
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw const ShareApiException('Download failed. Try again in a moment.');
      }

      final directory = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory('${directory.path}/SwiftShare/Downloads');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final filename = _filenameFromHeaders(response.headers) ?? sharedFile.filename;
      final file = File('${downloadsDir.path}/${_sanitizeFilename(filename)}');
      await file.writeAsBytes(response.bodyBytes);

      return DownloadedSharedFile(file: file, filename: filename);
    } on ShareApiException {
      rethrow;
    } catch (_) {
      throw const ShareApiException('Could not save the downloaded file.');
    }
  }

  static String? extractCode(String value) {
    final text = value.trim();
    final rawCode = normalizeCode(text);
    if (rawCode != null) return rawCode;

    final uri = Uri.tryParse(text);
    if (uri == null) return null;

    final queryCode = uri.queryParameters['code'];
    final normalizedQueryCode = normalizeCode(queryCode ?? '');
    if (normalizedQueryCode != null) return normalizedQueryCode;

    final segments = uri.pathSegments;
    for (var i = 0; i < segments.length; i++) {
      if ((segments[i] == 'download' || segments[i] == 'file' || segments[i] == 'qr') &&
          i + 1 < segments.length) {
        final normalizedPathCode = normalizeCode(segments[i + 1]);
        if (normalizedPathCode != null) return normalizedPathCode;
      }
    }

    return null;
  }

  static String? normalizeCode(String value) {
    final normalized = value.trim().toUpperCase();
    final validCode = RegExp(r'^[A-Z0-9]{6}$');
    return validCode.hasMatch(normalized) ? normalized : null;
  }

  Map<String, dynamic> _decodeJson(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw const ShareApiException('Backend response was invalid.');
  }

  String? _filenameFromHeaders(Map<String, String> headers) {
    final disposition = headers['content-disposition'];
    if (disposition == null) return null;

    final match = RegExp(r'filename="?([^";]+)"?').firstMatch(disposition);
    return match?.group(1);
  }

  String _sanitizeFilename(String filename) {
    final sanitized = filename.replaceAll(RegExp(r'[^\w.\-]'), '_').replaceAll(RegExp(r'^\.+'), '');
    return sanitized.isEmpty ? 'swiftshare-file' : sanitized;
  }
}
