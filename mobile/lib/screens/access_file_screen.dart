import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_config.dart';
import '../models/shared_file.dart';
import '../providers/share_provider.dart';
import '../services/share_api_service.dart';
import '../utils/theme.dart';

class AccessFileScreen extends StatefulWidget {
  final String? initialCode;

  const AccessFileScreen({super.key, this.initialCode});

  @override
  State<AccessFileScreen> createState() => _AccessFileScreenState();
}

class _AccessFileScreenState extends State<AccessFileScreen> {
  late final TextEditingController _codeController;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.initialCode ?? '');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final code = ShareApiService.normalizeCode(_codeController.text);
      if (code != null) {
        context.read<ShareProvider>().lookupCode(code);
      }
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.background,
      body: SafeArea(
        child: Consumer<ShareProvider>(
          builder: (context, shareProvider, child) {
            final file = shareProvider.foundFile;
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              children: [
                _buildHeader(context),
                const SizedBox(height: 26),
                Text(
                  'Access a shared file',
                  style: AppTextStyles.heading2.copyWith(
                    color: context.palette.textPrimary,
                    fontSize: 28,
                    height: 1.05,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter the six-character code from web, another phone, or a QR scan.',
                  style: AppTextStyles.body2.copyWith(
                    color: context.palette.textSecondary,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 18),
                _buildLookupCard(shareProvider),
                if (shareProvider.error != null) ...[
                  const SizedBox(height: 14),
                  _ErrorBox(message: shareProvider.error!),
                ],
                if (file != null) ...[
                  const SizedBox(height: 18),
                  _SharedFileAccessCard(
                    file: file,
                    isDownloading: shareProvider.isDownloading,
                    savedPath: shareProvider.downloadedFile?.file.path,
                    onDownload: shareProvider.downloadFoundFile,
                  ),
                ],
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
        _CircleButton(
          icon: Icons.arrow_back,
          onTap: () => Navigator.pop(context),
        ),
        const Spacer(),
        Container(
          width: 44,
          height: 44,
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
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.24),
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: const Icon(Icons.file_download_outlined,
              color: Colors.white, size: 24),
        ),
      ],
    );
  }

  Widget _buildLookupCard(ShareProvider shareProvider) {
    return _Panel(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 68,
              height: 68,
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
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.file_download_outlined,
                  color: AppColors.primary, size: 38),
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _codeController,
            maxLength: 6,
            textAlign: TextAlign.center,
            textCapitalization: TextCapitalization.characters,
            style: AppTextStyles.heading3.copyWith(
              color: context.palette.textPrimary,
              letterSpacing: 2,
              fontWeight: FontWeight.w800,
            ),
            decoration: InputDecoration(
              counterText: '',
              hintText: 'ABC123',
              prefixIcon: const Icon(Icons.tag, color: AppColors.primary),
              filled: true,
              fillColor: context.palette.surfaceSubtle,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: context.palette.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: context.palette.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.6),
              ),
            ),
            onChanged: (value) {
              final upper = value.toUpperCase();
              if (value != upper) {
                _codeController.value = TextEditingValue(
                  text: upper,
                  selection: TextSelection.collapsed(offset: upper.length),
                );
              }
            },
            onSubmitted: (_) => _lookup(shareProvider),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: shareProvider.isLookingUp
                  ? null
                  : () => _lookup(shareProvider),
              icon: shareProvider.isLookingUp
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.search, size: 20),
              label: Text(shareProvider.isLookingUp
                  ? 'Finding file...'
                  : 'Find shared file'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 10,
                shadowColor: AppColors.primary.withValues(alpha: 0.35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _lookup(ShareProvider shareProvider) {
    final code = ShareApiService.normalizeCode(_codeController.text);
    if (code == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid six-character code.')),
      );
      return;
    }
    shareProvider.lookupCode(code);
  }
}

class _SharedFileAccessCard extends StatelessWidget {
  final SharedFile file;
  final bool isDownloading;
  final String? savedPath;
  final VoidCallback onDownload;

  const _SharedFileAccessCard({
    required this.file,
    required this.isDownloading,
    required this.savedPath,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.insert_drive_file,
                    color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  file.filename,
                  style: AppTextStyles.body1.copyWith(
                    color: context.palette.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoRow(label: 'Size', value: AppConfig.formatFileSize(file.size)),
          _InfoRow(label: 'Code', value: file.code),
          _InfoRow(label: 'Downloads', value: '${file.downloadsLeft} left'),
          _InfoRow(
              label: 'Expires', value: file.expiresAt.toLocal().toString()),
          if (savedPath != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Saved to $savedPath',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          const SizedBox(height: 18),
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              icon: isDownloading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.download, size: 20),
              label: Text(isDownloading ? 'Downloading...' : 'Download file'),
              onPressed: isDownloading ? null : onDownload,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 10,
                shadowColor: AppColors.primary.withValues(alpha: 0.35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 86,
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: context.palette.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body2.copyWith(
                color: context.palette.textBody,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  State<_CircleButton> createState() => _CircleButtonState();
}

class _CircleButtonState extends State<_CircleButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: context.palette.surface,
            shape: BoxShape.circle,
            border: Border.all(color: context.palette.border),
            boxShadow: [
              BoxShadow(
                color: context.palette.shadow,
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(widget.icon, color: context.palette.textBody, size: 20),
        ),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;

  const _ErrorBox({required this.message});

  @override
  Widget build(BuildContext context) {
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
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(18),
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
