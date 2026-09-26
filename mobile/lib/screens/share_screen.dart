import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../config/app_config.dart';
import '../models/shared_file.dart';
import '../providers/share_provider.dart';
import '../utils/theme.dart';
import 'access_file_screen.dart';
import 'qr_scanner_screen.dart';

class ShareScreen extends StatefulWidget {
  const ShareScreen({super.key});

  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

// One duration and curve for the whole File/Text switch, so the tab pill,
// the panel fade and the height change move together.
const Duration _modeSwitchDuration = Duration(milliseconds: 240);
const Curve _modeSwitchCurve = Curves.easeOutCubic;

class _ShareScreenState extends State<ShareScreen> {
  int _maxDownloads = 1;
  bool _textMode = false;

  void _setTextMode(bool value) {
    if (_textMode == value) return;
    HapticFeedback.selectionClick();
    // Close the keyboard so it doesn't resize the page mid-animation.
    FocusScope.of(context).unfocus();
    setState(() => _textMode = value);
  }
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _filenameController =
      TextEditingController(text: 'swiftshare-note.txt');

  @override
  void dispose() {
    _textController.dispose();
    _filenameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<ShareProvider>(
          builder: (context, shareProvider, child) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                Text(
                  'Share files online',
                  style: AppTextStyles.heading2.copyWith(
                    color: Colors.black,
                    fontSize: 28,
                    height: 1.05,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Upload from your phone and open it on web with a temporary code, link, or QR.',
                  style: AppTextStyles.body2.copyWith(
                    color: const Color(0xFF60708C),
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 18),
                _buildModeSelector(),
                const SizedBox(height: 16),
                AnimatedSize(
                  duration: _modeSwitchDuration,
                  curve: _modeSwitchCurve,
                  alignment: Alignment.topCenter,
                  clipBehavior: Clip.none, // keep the panel shadow visible
                  child: AnimatedSwitcher(
                    duration: _modeSwitchDuration,
                    reverseDuration: const Duration(milliseconds: 140),
                    switchInCurve: _modeSwitchCurve,
                    switchOutCurve: Curves.easeInCubic,
                    // The outgoing panel is overlaid (positioned), so only the
                    // incoming panel decides the height: no double resize.
                    layoutBuilder: (current, previous) => Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.topCenter,
                      children: [
                        for (final child in previous)
                          Positioned(top: 0, left: 0, right: 0, child: child),
                        if (current != null) current,
                      ],
                    ),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.02),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: _textMode
                        ? KeyedSubtree(
                            key: const ValueKey('text-panel'),
                            child: _buildTextUpload(shareProvider),
                          )
                        : KeyedSubtree(
                            key: const ValueKey('file-panel'),
                            child: _buildFileUpload(shareProvider),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildDownloadLimit(),
                if (shareProvider.error != null) ...[
                  const SizedBox(height: 14),
                  _buildError(shareProvider.error!),
                ],
                if (shareProvider.uploadedFile != null) ...[
                  const SizedBox(height: 18),
                  _SharedFileResult(file: shareProvider.uploadedFile!),
                ],
                const SizedBox(height: 10),
                _buildAccessButton(context),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.28),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.share_rounded, color: Colors.white, size: 19),
        ),
        const SizedBox(width: 10),
        Text(
          'SwiftShare',
          style: AppTextStyles.body1.copyWith(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        _CircleAction(
          tooltip: 'Scan QR',
          icon: Icons.qr_code_scanner,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const QRScannerScreen()),
            );
          },
        ),
        const SizedBox(width: 10),
        _CircleAction(
          tooltip: 'Access file',
          icon: Icons.file_download_outlined,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AccessFileScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildModeSelector() {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF3FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4EAF3)),
      ),
      child: Stack(
        children: [
          // One white pill that slides between the tabs, instead of two
          // backgrounds fading in and out (which caused the flicker).
          Positioned.fill(
            child: AnimatedAlign(
              alignment:
                  _textMode ? Alignment.centerRight : Alignment.centerLeft,
              duration: _modeSwitchDuration,
              curve: _modeSwitchCurve,
              child: FractionallySizedBox(
                widthFactor: 0.5,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(11),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _ModeTab(
                  selected: !_textMode,
                  icon: Icons.insert_drive_file_outlined,
                  label: 'File',
                  onTap: () => _setTextMode(false),
                ),
              ),
              Expanded(
                child: _ModeTab(
                  selected: _textMode,
                  icon: Icons.notes,
                  label: 'Text',
                  onTap: () => _setTextMode(true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Same look for both panels' main button, so switching doesn't blend two
  /// differently styled buttons into each other.
  Widget _primaryButton({
    required bool busy,
    required IconData icon,
    required String label,
    required String busyLabel,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 48,
      child: ElevatedButton.icon(
        icon: busy
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Icon(icon, size: 20),
        label: Text(busy ? busyLabel : label),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.7),
          disabledForegroundColor: Colors.white,
          elevation: 8,
          shadowColor: AppColors.primary.withValues(alpha: 0.32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
          ),
        ),
        onPressed: busy ? null : onPressed,
      ),
    );
  }

  Widget _buildFileUpload(ShareProvider shareProvider) {
    return _Panel(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF8FAFF), Color(0xFFE9ECFF)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.cloud_upload_outlined,
                  size: 40, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Choose a file from this phone',
            textAlign: TextAlign.center,
            style: AppTextStyles.heading3.copyWith(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Up to ${AppConfig.formatFileSize(AppConfig.maxFileSize)}. The backend creates a code, QR, and download link.',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(
              color: const Color(0xFF9AA7BC),
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          _primaryButton(
            busy: shareProvider.isUploading,
            icon: Icons.description,
            label: 'Select and upload',
            busyLabel: 'Uploading...',
            onPressed: () => _pickAndUploadFile(shareProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildTextUpload(ShareProvider shareProvider) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _filenameController,
            decoration: const InputDecoration(
              labelText: 'Filename',
              prefixIcon: Icon(Icons.description),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _textController,
            minLines: 6,
            maxLines: 10,
            decoration: const InputDecoration(
              labelText: 'Paste text',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),
          _primaryButton(
            busy: shareProvider.isUploading,
            icon: Icons.link,
            label: 'Create share link',
            busyLabel: 'Creating link...',
            onPressed: () => shareProvider.uploadText(
              _textController.text,
              filename: _filenameController.text,
              maxDownloads: _maxDownloads,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadLimit() {
    return _Panel(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    const Icon(Icons.check, color: AppColors.primary, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Max downloads',
                  style: AppTextStyles.body2.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                height: 34,
                padding: const EdgeInsets.only(left: 12, right: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFD),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5EBF4)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _maxDownloads,
                    borderRadius: BorderRadius.circular(12),
                    icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                    items: List.generate(10, (index) => index + 1)
                        .map((value) => DropdownMenuItem(
                            value: value, child: Text(value.toString())))
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _maxDownloads = value;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.schedule, color: Color(0xFF94A3B8), size: 16),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Auto expiration',
                  style: AppTextStyles.caption.copyWith(
                    color: const Color(0xFF8FA0B8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '24 hours',
                  style: AppTextStyles.caption.copyWith(
                    color: const Color(0xFF334155),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccessButton(BuildContext context) {
    return SizedBox(
      height: 46,
      child: OutlinedButton.icon(
        icon: const Icon(Icons.file_download_outlined, size: 20),
        label: const Text('Access a shared file'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF24324B),
          backgroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFFDDE5F0)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AccessFileScreen()),
          );
        },
      ),
    );
  }

  Widget _buildError(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadFile(ShareProvider shareProvider) async {
    final result = await FilePicker.pickFile(type: FileType.any);
    final path = result?.path;
    if (path == null) return;

    await shareProvider.uploadFile(File(path), maxDownloads: _maxDownloads);
  }
}

class _CircleAction extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  const _CircleAction({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE5EBF4)),
          ),
          child: Icon(icon, color: const Color(0xFF334155), size: 20),
        ),
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ModeTab({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color color =
        selected ? AppColors.primary : const Color(0xFF64748B);
    // The sliding pill behind the tabs is the selection indicator, so the tab
    // itself is transparent and has no ink splash (the splash was drawn
    // behind the pill and showed as a grey flash).
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: TweenAnimationBuilder<Color?>(
          tween: ColorTween(end: color),
          duration: _modeSwitchDuration,
          curve: _modeSwitchCurve,
          builder: (context, animatedColor, _) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: animatedColor),
              const SizedBox(width: 7),
              Text(
                label,
                style: AppTextStyles.body2.copyWith(
                  color: animatedColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SharedFileResult extends StatelessWidget {
  final SharedFile file;

  const _SharedFileResult({required this.file});

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.success),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Ready to share',
                  style: AppTextStyles.heading3
                      .copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: QrImageView(
              data: file.url,
              version: QrVersions.auto,
              size: 180,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _InfoRow(label: 'File', value: file.filename),
          _InfoRow(label: 'Size', value: AppConfig.formatFileSize(file.size)),
          _InfoRow(label: 'Code', value: file.code),
          _InfoRow(label: 'Downloads', value: '${file.downloadsLeft} left'),
          _InfoRow(
              label: 'Expires', value: file.expiresAt.toLocal().toString()),
          const SizedBox(height: 12),
          SelectableText(
            file.url,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.copy),
                label: const Text('Copy code'),
                onPressed: () => _copy(context, file.code, 'Code copied'),
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.link),
                label: const Text('Copy link'),
                onPressed: () => _copy(context, file.url, 'Link copied'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _copy(BuildContext context, String value, String message) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _Panel({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5EBF4)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF53617A).withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}
