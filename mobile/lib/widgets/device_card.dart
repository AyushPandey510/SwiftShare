import 'package:flutter/material.dart';
import 'package:swiftshare_mobile/providers/device_provider.dart';
import 'package:swiftshare_mobile/utils/theme.dart';

class DeviceCard extends StatefulWidget {
  final Device device;
  final VoidCallback? onTap;

  const DeviceCard({
    super.key,
    required this.device,
    this.onTap,
  });

  @override
  State<DeviceCard> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDurations.normal,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _shadowAnimation = Tween<double>(begin: 8.0, end: 2.0).animate(
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
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: AppOpacity.faint),
                  blurRadius: _shadowAnimation.value,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: AppOpacity.hairline),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
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
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: AppOpacity.subtle),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Device Icon with enhanced styling
                      Container(
                        width: AppSizes.iconTileLg,
                        height: AppSizes.iconTileLg,
                        decoration: BoxDecoration(
                          color: context.isDark
                              ? context.palette.accentSoft
                              : null,
                          gradient: context.isDark
                              ? null
                              : LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.primary.withValues(alpha: AppOpacity.soft),
                                    AppColors.secondary.withValues(alpha: AppOpacity.subtle),
                                  ],
                                ),
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: AppOpacity.medium),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _getDeviceProvider().getDeviceTypeIcon(widget.device.type),
                            style: const TextStyle(
                              fontSize: AppFontSize.display,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: AppSpacing.xl),
                      
                      // Device Info with improved typography
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.device.name,
                                    style: AppTextStyles.heading3.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: AppSpacing.sm,
                                  ),
                                  decoration: BoxDecoration(
                                    color: widget.device.isOnline 
                                        ? AppColors.success.withValues(alpha: AppOpacity.soft)
                                        : AppColors.error.withValues(alpha: AppOpacity.soft),
                                    borderRadius: BorderRadius.circular(AppRadius.md),
                                    border: Border.all(
                                      color: widget.device.isOnline 
                                          ? AppColors.success.withValues(alpha: AppOpacity.strong)
                                          : AppColors.error.withValues(alpha: AppOpacity.strong),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    widget.device.isOnline ? 'Online' : 'Offline',
                                    style: AppTextStyles.caption.copyWith(
                                      color: widget.device.isOnline 
                                          ? AppColors.success 
                                          : AppColors.error,
                                      fontWeight: FontWeight.w700,
                                      fontSize: AppFontSize.xxs,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              widget.device.address,
                              style: AppTextStyles.body2.copyWith(
                                color: context.palette.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: AppIconSize.sm,
                                  color: context.palette.textSecondary,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  _getDeviceProvider().formatLastSeen(widget.device.lastSeen),
                                  style: AppTextStyles.caption.copyWith(
                                    color: context.palette.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.xl),
                                if (widget.device.capabilities.isNotEmpty) ...[
                                  Icon(
                                    Icons.security,
                                    size: AppIconSize.sm,
                                    color: widget.device.capabilities.contains('Encryption')
                                        ? AppColors.success
                                        : context.palette.textMuted,
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Text(
                                    widget.device.capabilities.contains('Encryption') ? 'Encrypted' : 'Standard',
                                    style: AppTextStyles.caption.copyWith(
                                      color: widget.device.capabilities.contains('Encryption')
                                          ? AppColors.success
                                          : context.palette.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Enhanced action icon
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: AppIconSize.md,
                          color: context.palette.textSecondary,
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

  DeviceProvider _getDeviceProvider() {
    return DeviceProvider();
  }
} 