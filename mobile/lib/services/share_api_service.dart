import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../config/app_config.dart';
import '../models/shared_file.dart';

class ShareApiException implements Exception {
  final String message;

  const ShareApiException(this.message);

  @override
  String toString() => message;
}

/// Called while a download streams in. [total] is null if the size is unknown.
typedef DownloadProgressCallback = void Function(int received, int? total);

class DownloadedSharedFile {
  final File file;
  final String filename;

  /// Human-readable location, e.g. "Downloads/SwiftShare/report.pdf".
  final String location;

  /// True when saved to the phone's shared Downloads folder (visible in the
  /// Files app); false when it had to fall back to the app's own storage.
  final bool isPublic;

  const DownloadedSharedFile({
    required this.file,
    required this.filename,
    required this.location,
    required this.isPublic,
  });
}

class _SaveDir {
  final Directory dir;
  final String label;
  final bool isPublic;

  const _SaveDir(this.dir, this.label, this.isPublic);
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

  /// Streams the file straight to disk (never holds it all in memory),
  /// reports progress, and saves it to Downloads/SwiftShare so it shows up in
  /// the phone's Files app.
  Future<DownloadedSharedFile> downloadFile(
    SharedFile sharedFile, {
    DownloadProgressCallback? onProgress,
  }) async {
    final client = http.Client();
    File? partial;
    try {
      final request = http.Request(
        'GET',
        Uri.parse('${AppConfig.getFullUrl(AppConfig.apiDownload)}/${sharedFile.code}'),
      );
      // Generous: the hosted server may need up to a minute to wake up.
      final response =
          await client.send(request).timeout(const Duration(seconds: 75));

      if (response.statusCode == 404) {
        throw const ShareApiException('No file was found for that code.');
      }
      if (response.statusCode == 410) {
        throw const ShareApiException(
            'This file has expired or reached its download limit.');
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw const ShareApiException('Download failed. Try again in a moment.');
      }

      final filename = _sanitizeFilename(
          _filenameFromHeaders(response.headers) ?? sharedFile.filename);
      final saveDir = await _resolveSaveDir();
      final target = await _uniqueFile(saveDir.dir, filename);

      // Write to "<name>.part" first so a broken download never leaves a
      // half file that looks complete.
      partial = File('${target.path}.part');
      final sink = partial.openWrite();
      final int? total = response.contentLength ??
          (sharedFile.size > 0 ? sharedFile.size : null);
      var received = 0;
      try {
        await for (final chunk
            in response.stream.timeout(const Duration(seconds: 30))) {
          sink.add(chunk);
          received += chunk.length;
          onProgress?.call(received, total);
        }
        await sink.flush();
      } finally {
        await sink.close();
      }

      if (total != null && received < total) {
        throw const ShareApiException(
            'The download was interrupted. Check your connection and try again.');
      }

      final file = await partial.rename(target.path);
      partial = null;
      final savedName = file.uri.pathSegments.last;
      return DownloadedSharedFile(
        file: file,
        filename: savedName,
        location: '${saveDir.label}/$savedName',
        isPublic: saveDir.isPublic,
      );
    } on ShareApiException {
      rethrow;
    } on TimeoutException {
      throw const ShareApiException(
          'The server took too long to respond. It may be waking up - try again in a minute.');
    } on SocketException {
      throw const ShareApiException(
          'No connection to the server. Check your internet and try again.');
    } on http.ClientException {
      throw const ShareApiException(
          'The connection dropped during the download. Please try again.');
    } on FileSystemException {
      throw const ShareApiException(
          'Could not save the file on this phone. Check free storage and try again.');
    } catch (_) {
      throw const ShareApiException('Download failed. Please try again.');
    } finally {
      client.close();
      final leftover = partial;
      if (leftover != null) {
        try {
          if (await leftover.exists()) await leftover.delete();
        } catch (_) {}
      }
    }
  }

  /// Downloads/SwiftShare when we can write there, otherwise the app's own
  /// folder (always writable, but only reachable from inside the app).
  Future<_SaveDir> _resolveSaveDir() async {
    final publicDir = await _publicDownloadsDir();
    if (publicDir != null) {
      if (await _canWrite(publicDir)) {
        return _SaveDir(publicDir, 'Downloads/SwiftShare', true);
      }
      // Android 10 and older need the storage permission for Downloads.
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (status.isGranted && await _canWrite(publicDir)) {
          return _SaveDir(publicDir, 'Downloads/SwiftShare', true);
        }
      }
    }

    final docs = await getApplicationDocumentsDirectory();
    final appDir = Directory('${docs.path}/SwiftShare/Downloads');
    await appDir.create(recursive: true);
    return _SaveDir(appDir, 'SwiftShare app storage', false);
  }

  /// /storage/emulated/0/Download/SwiftShare on Android, null elsewhere.
  Future<Directory?> _publicDownloadsDir() async {
    if (!Platform.isAndroid) return null;
    try {
      final external = await getExternalStorageDirectory();
      if (external == null) return null;
      // e.g. /storage/emulated/0/Android/data/<package>/files -> /storage/emulated/0
      final root = external.path.split('/Android/').first;
      return Directory('$root/Download/SwiftShare');
    } catch (_) {
      return null;
    }
  }

  Future<bool> _canWrite(Directory dir) async {
    try {
      await dir.create(recursive: true);
      final probe = File('${dir.path}/.swiftshare_write_test');
      await probe.writeAsString('ok', flush: true);
      await probe.delete();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// "report.pdf" -> "report (1).pdf" if a file with that name already exists.
  Future<File> _uniqueFile(Directory dir, String filename) async {
    var candidate = File('${dir.path}/$filename');
    if (!await candidate.exists()) return candidate;

    final dot = filename.lastIndexOf('.');
    final base = dot > 0 ? filename.substring(0, dot) : filename;
    final ext = dot > 0 ? filename.substring(dot) : '';
    for (var i = 1; i < 1000; i++) {
      candidate = File('${dir.path}/$base ($i)$ext');
      if (!await candidate.exists()) return candidate;
    }
    return File('${dir.path}/$base-${DateTime.now().millisecondsSinceEpoch}$ext');
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
