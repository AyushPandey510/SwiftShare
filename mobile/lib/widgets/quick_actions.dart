import 'package:flutter/material.dart';
import 'package:swiftshare_mobile/utils/theme.dart';
import 'package:swiftshare_mobile/screens/qr_scanner_screen.dart';

class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Quick Actions',
              style: AppTextStyles.heading3.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: AppOpacity.subtle),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                '4 Actions',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.file_upload,
                title: 'Send File',
                subtitle: 'Share a file',
                color: AppColors.primary,
                onTap: () => _showFilePicker(context),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.folder_open,
                title: 'Send Folder',
                subtitle: 'Share a folder',
                color: AppColors.secondary,
                onTap: () => _showFolderPicker(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.qr_code_scanner,
                title: 'Scan QR',
                subtitle: 'Connect via QR',
                color: AppColors.accent,
                onTap: () => _showQRScanner(context),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.history,
                title: 'History',
                subtitle: 'View transfers',
                color: AppColors.warning,
                onTap: () => _showHistory(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showFilePicker(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Choose a nearby device first, then send a file.')),
    );
  }

  void _showFolderPicker(BuildContext context) {
    // TODO: Implement folder picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Folder sharing coming soon!')),
    );
  }

  void _showQRScanner(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const QRScannerScreen(),
      ),
    );
  }

  void _showHistory(BuildContext context) {
    // TODO: Navigate to history screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('History coming soon!')),
    );
  }
}

class _QuickActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDurations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _shadowAnimation = Tween<double>(begin: 6.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: AppOpacity.faint),
                  blurRadius: _shadowAnimation.value,
                  offset: const Offset(0, 3),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: AppOpacity.hairline),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                onTapDown: (_) => _controller.forward(),
                onTapUp: (_) => _controller.reverse(),
                onTapCancel: () => _controller.reverse(),
                borderRadius: BorderRadius.circular(AppRadius.xl),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: AppOpacity.faint),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Enhanced Icon Container
                      Container(
                        width: AppSizes.buttonHeight,
                        height: AppSizes.buttonHeight,
                        decoration: BoxDecoration(
                          color: context.isDark
                              ? Color.alphaBlend(
                                  widget.color.withValues(alpha: AppOpacity.medium),
                                  context.palette.surface,
                                )
                              : null,
                          gradient: context.isDark
                              ? null
                              : LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    widget.color.withValues(alpha: AppOpacity.soft),
                                    widget.color.withValues(alpha: AppOpacity.faint),
                                  ],
                                ),
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(
                            color: widget.color.withValues(alpha: AppOpacity.medium),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          widget.icon,
                          color: widget.color,
                          size: AppIconSize.xl,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        widget.title,
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: AppFontSize.md,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        widget.subtitle,
                        style: AppTextStyles.caption.copyWith(
                          color: context.palette.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
} 
