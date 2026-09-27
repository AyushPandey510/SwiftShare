import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swiftshare_mobile/providers/transfer_provider.dart';
import 'package:swiftshare_mobile/utils/theme.dart';

class TransferSummaryWidget extends StatelessWidget {
  const TransferSummaryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TransferProvider>(
      builder: (context, transferProvider, child) {
        final completedTransfers = transferProvider.completedTransfers;
        final activeTransfers = transferProvider.activeTransfers;
        final failedTransfers = transferProvider.failedTransfers;

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: AppOpacity.faint),
                blurRadius: 8,
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
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: AppOpacity.faint),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Transfer Summary',
                      style: AppTextStyles.heading3.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (activeTransfers.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: AppOpacity.soft),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: AppOpacity.strong),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '${activeTransfers.length} Active',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: AppFontSize.xxs,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: _SummaryItem(
                        icon: Icons.check_circle,
                        title: 'Completed',
                        value: completedTransfers.length.toString(),
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: _SummaryItem(
                        icon: Icons.sync,
                        title: 'Active',
                        value: activeTransfers.length.toString(),
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: _SummaryItem(
                        icon: Icons.error,
                        title: 'Failed',
                        value: failedTransfers.length.toString(),
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
                if (activeTransfers.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xl),
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      color: context.isDark ? context.palette.border : null,
                      gradient: context.isDark
                          ? null
                          : LinearGradient(
                              colors: [
                                Colors.transparent,
                                Theme.of(context)
                                    .colorScheme
                                    .outline
                                    .withValues(alpha: AppOpacity.medium),
                                Colors.transparent,
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Active Transfers',
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: AppFontSize.md,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ...activeTransfers.map((transfer) => _ActiveTransferItem(
                    transfer: transfer,
                    transferProvider: transferProvider,
                  )),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _SummaryItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: color.withValues(alpha: AppOpacity.faint),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: color.withValues(alpha: AppOpacity.medium),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: AppSizes.iconTile,
            height: AppSizes.iconTile,
            decoration: BoxDecoration(
              color: color.withValues(alpha: AppOpacity.soft),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              icon,
              color: color,
              size: AppIconSize.lg,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: AppTextStyles.heading3.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            title,
            style: AppTextStyles.caption.copyWith(
              color: context.palette.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveTransferItem extends StatelessWidget {
  final TransferItem transfer;
  final TransferProvider transferProvider;

  const _ActiveTransferItem({
    required this.transfer,
    required this.transferProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: AppOpacity.subtle),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  transfer.fileName,
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: AppOpacity.soft),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  '${(transfer.progress * 100).toInt()}%',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          LinearProgressIndicator(
            value: transfer.progress,
            backgroundColor: Theme.of(context).colorScheme.outline.withValues(alpha: AppOpacity.medium),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: AppIconSize.xs,
                color: context.palette.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                transferProvider.formatTransferTime(transfer.startTime),
                style: AppTextStyles.caption.copyWith(
                  color: context.palette.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                transferProvider.formatFileSize(transfer.fileSize),
                style: AppTextStyles.caption.copyWith(
                  color: context.palette.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 