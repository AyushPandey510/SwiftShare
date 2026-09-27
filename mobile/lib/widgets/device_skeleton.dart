import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../utils/theme.dart';

class DeviceSkeleton extends StatelessWidget {
  const DeviceSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.palette.surfaceMuted,
      highlightColor: context.palette.surface,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: AppOpacity.subtle),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Device Icon Skeleton
            Container(
              width: AppSizes.iconTileLg,
              height: AppSizes.iconTileLg,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
            
            const SizedBox(width: AppSpacing.xl),
            
            // Device Info Skeleton
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppRadius.xs),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Container(
                        width: 60,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    width: 120,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xl),
                      Container(
                        width: 60,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Action Icon Skeleton
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DeviceListSkeleton extends StatelessWidget {
  final int count;
  
  const DeviceListSkeleton({super.key, this.count = 3});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(count, (index) => const DeviceSkeleton()),
    );
  }
} 