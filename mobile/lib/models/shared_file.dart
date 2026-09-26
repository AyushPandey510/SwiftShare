class SharedFile {
  final String id;
  final String code;
  final String filename;
  final int size;
  final String type;
  final String url;
  final String qrUrl;
  final DateTime expiresAt;
  final int downloadCount;
  final int maxDownloads;
  final DateTime uploadedAt;
  final String? uploadedBy;

  const SharedFile({
    required this.id,
    required this.code,
    required this.filename,
    required this.size,
    required this.type,
    required this.url,
    required this.qrUrl,
    required this.expiresAt,
    required this.downloadCount,
    required this.maxDownloads,
    required this.uploadedAt,
    this.uploadedBy,
  });

  int get downloadsLeft => (maxDownloads - downloadCount).clamp(0, maxDownloads);

  factory SharedFile.fromJson(Map<String, dynamic> json) {
    return SharedFile(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      filename: json['filename']?.toString() ?? 'shared-file',
      size: _parseInt(json['size']),
      type: json['type']?.toString() ?? 'application/octet-stream',
      url: json['url']?.toString() ?? '',
      qrUrl: json['qrUrl']?.toString() ?? '',
      expiresAt: _parseDate(json['expiresAt']),
      downloadCount: _parseInt(json['downloadCount']),
      maxDownloads: _parseInt(json['maxDownloads'], fallback: 1),
      uploadedAt: _parseDate(json['uploadedAt']),
      uploadedBy: json['uploadedBy']?.toString(),
    );
  }

  static int _parseInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static DateTime _parseDate(dynamic value) {
    return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
  }
}
