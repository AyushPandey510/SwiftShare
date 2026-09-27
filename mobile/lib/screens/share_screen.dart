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
const Duration _modeSwitchDuration = AppDurations.medium;
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
      backgroundColor: context.palette.background,
      body: SafeArea(
        child: Consumer<ShareProvider>(
          builder: (context, shareProvider, child) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.xxl),
              children: [
                _buildHeader(context),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  'Share files online',
                  style: AppTextStyles.heading2.copyWith(
                    color: context.palette.textPrimary,
                    fontSize: AppFontSize.display,
                    height: 1.05,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Upload from your phone and open it on web with a temporary code, link, or QR.',
                  style: AppTextStyles.body2.copyWith(
                    color: context.palette.textSecondary,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                _buildModeSelector(),
                const SizedBox(height: AppSpacing.lg),
                AnimatedSize(
                  duration: _modeSwitchDuration,
                  curve: _modeSwitchCurve,
                  alignment: Alignment.topCenter,
                  clipBehavior: Clip.none, // keep the panel shadow visible
                  child: AnimatedSwitcher(
                    duration: _modeSwitchDuration,
                    reverseDuration: AppDurations.fast,
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
                const SizedBox(height: AppSpacing.lg),
                _buildDownloadLimit(),
                if (shareProvider.error != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _buildError(shareProvider.error!),
                ],
                if (shareProvider.uploadedFile != null) ...[
                  const SizedBox(height: AppSpacing.xl),
                  _SharedFileResult(file: shareProvider.uploadedFile!),
                ],
                const SizedBox(height: AppSpacing.md),
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
            // Dark mode: solid brand colour instead of the gradient.
            color: context.isDark ? AppColors.primary : null,
            gradient: context.isDark
                ? null
                : const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: AppOpacity.quarter),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.share_rounded, color: Colors.white, size: AppIconSize.lg),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          'SwiftShare',
          style: AppTextStyles.body1.copyWith(
            color: context.palette.textPrimary,
            fontSize: AppFontSize.lg,
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
        const SizedBox(width: AppSpacing.md),
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
      height: AppSizes.iconButton,
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: context.palette.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.palette.border),
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
                    color: context.palette.surface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: AppOpacity.faint),
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
      height: AppSizes.buttonHeight,
      child: ElevatedButton.icon(
        icon: busy
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Icon(icon, size: AppIconSize.lg),
        label: Text(busy ? busyLabel : label),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: AppOpacity.overlay),
          disabledForegroundColor: Colors.white,
          elevation: 8,
          shadowColor: AppColors.primary.withValues(alpha: AppOpacity.strong),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          textStyle: const TextStyle(
            fontSize: AppFontSize.sm,
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
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: AppSizes.iconTileXl,
              height: AppSizes.iconTileXl,
              decoration: BoxDecoration(
                color: context.isDark ? context.palette.accentSoft : null,
                gradient: context.isDark
                    ? null
                    : LinearGradient(
                        colors: [
                          context.palette.accentSoftTop,
                          context.palette.accentSoft,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                borderRadius: BorderRadius.circular(AppRadius.xl),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: AppOpacity.subtle),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.cloud_upload_outlined,
                  size: AppIconSize.xxl, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Choose a file from this phone',
            textAlign: TextAlign.center,
            style: AppTextStyles.heading3.copyWith(
              color: context.palette.textPrimary,
              fontSize: AppFontSize.lg,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Up to ${AppConfig.formatFileSize(AppConfig.maxFileSize)}. The backend creates a code, QR, and download link.',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(
              color: context.palette.textMuted,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
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
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _textController,
            minLines: 6,
            maxLines: 10,
            decoration: const InputDecoration(
              labelText: 'Paste text',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
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
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: AppOpacity.faint),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child:
                    const Icon(Icons.check, color: AppColors.primary, size: AppIconSize.sm),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Max downloads',
                  style: AppTextStyles.body2.copyWith(
                    color: context.palette.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                height: 34,
                padding: const EdgeInsets.only(left: AppSpacing.md, right: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: context.palette.surfaceSubtle,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: context.palette.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _maxDownloads,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    icon: const Icon(Icons.keyboard_arrow_down, size: AppIconSize.lg),
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
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Icon(Icons.schedule, color: context.palette.textMuted, size: AppIconSize.sm),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Auto expiration',
                  style: AppTextStyles.caption.copyWith(
                    color: context.palette.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: context.palette.surfaceSubtle,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  '24 hours',
                  style: AppTextStyles.caption.copyWith(
                    color: context.palette.textBody,
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
        icon: const Icon(Icons.file_download_outlined, size: AppIconSize.lg),
        label: const Text('Access a shared file'),
        style: OutlinedButton.styleFrom(
          foregroundColor: context.palette.textBody,
          backgroundColor: context.palette.surface,
          side: BorderSide(color: context.palette.borderStrong),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          textStyle: const TextStyle(
            fontSize: AppFontSize.sm,
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
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: AppOpacity.faint),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.error.withValues(alpha: AppOpacity.quarter)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: AppSpacing.sm),
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
          width: AppSizes.iconButton,
          height: AppSizes.iconButton,
          decoration: BoxDecoration(
            color: context.palette.surface,
            shape: BoxShape.circle,
            border: Border.all(color: context.palette.border),
          ),
          child: Icon(icon, color: context.palette.textBody, size: AppIconSize.lg),
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
        selected ? AppColors.primary : context.palette.textSecondary;
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
              Icon(icon, size: AppIconSize.sm, color: animatedColor),
              const SizedBox(width: AppSpacing.sm),
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
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Ready to share',
                  style: AppTextStyles.heading3
                      .copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: QrImageView(
              data: file.url,
              version: QrVersions.auto,
              size: 180,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _InfoRow(label: 'File', value: file.filename),
          _InfoRow(label: 'Size', value: AppConfig.formatFileSize(file.size)),
          _InfoRow(label: 'Code', value: file.code),
          _InfoRow(label: 'Downloads', value: '${file.downloadsLeft} left'),
          _InfoRow(
              label: 'Expires', value: file.expiresAt.toLocal().toString()),
          const SizedBox(height: AppSpacing.md),
          SelectableText(
            file.url,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.md),
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
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: context.palette.textSecondary,
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
    this.padding = const EdgeInsets.all(AppSpacing.lg),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: context.palette.border),
        boxShadow: [
          BoxShadow(
            color: context.palette.shadow,
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}
