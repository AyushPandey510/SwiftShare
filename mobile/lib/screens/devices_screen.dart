import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swiftshare_mobile/providers/device_provider.dart';
import 'package:swiftshare_mobile/providers/transfer_provider.dart';
import 'package:swiftshare_mobile/screens/qr_scanner_screen.dart';
import 'package:swiftshare_mobile/utils/theme.dart';
import 'package:swiftshare_mobile/widgets/device_card.dart';

class DevicesScreen extends StatelessWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.background,
      body: SafeArea(
        child: Consumer<DeviceProvider>(
          builder: (context, deviceProvider, child) {
            return RefreshIndicator(
              onRefresh: () => deviceProvider.refreshDevices(),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildHeader(context),
                  ),
                  SliverToBoxAdapter(
                    child: _buildNetworkInfo(context, deviceProvider),
                  ),

                  // Device Categories
                  SliverToBoxAdapter(
                    child: _buildDeviceCategories(context, deviceProvider),
                  ),
                  if (deviceProvider.discoveryError != null)
                    SliverToBoxAdapter(
                      child: _buildDiscoveryError(
                          context, deviceProvider.discoveryError!),
                    ),

                  // Devices List
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.xxl),
                    sliver: _buildDevicesList(context, deviceProvider),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.none),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Devices',
                  style: AppTextStyles.heading2.copyWith(
                    color: context.palette.textPrimary,
                    fontSize: AppFontSize.display,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Find nearby devices for direct sharing.',
                  style: AppTextStyles.body2.copyWith(
                    color: context.palette.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          _CircleAction(
            icon: Icons.qr_code_scanner,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QRScannerScreen()),
              );
            },
          ),
          const SizedBox(width: AppSpacing.md),
          _CircleAction(
            icon: Icons.refresh,
            onTap: () => context.read<DeviceProvider>().refreshDevices(),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkInfo(
      BuildContext context, DeviceProvider deviceProvider) {
    return Container(
      margin: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.isDark ? context.palette.accentSoft : null,
        gradient: context.isDark
            ? null
            : LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: AppOpacity.subtle),
                  AppColors.secondary.withValues(alpha: AppOpacity.subtle),
                ],
              ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.wifi,
                color: AppColors.primary,
                size: AppIconSize.xl,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Network Status',
                style: AppTextStyles.heading3.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _NetworkInfoItem(
                  icon: Icons.devices,
                  title: 'Devices Found',
                  value: deviceProvider.onlineDevices.length.toString(),
                ),
              ),
              Expanded(
                child: _NetworkInfoItem(
                  icon: Icons.location_on,
                  title: 'Local IP',
                  value: deviceProvider.localIpAddress.isNotEmpty
                      ? deviceProvider.localIpAddress
                      : 'Unknown',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCategories(
      BuildContext context, DeviceProvider deviceProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Device Types',
            style: AppTextStyles.heading3.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _DeviceTypeCard(
                  icon: '📱',
                  title: 'Mobile',
                  count:
                      deviceProvider.getDevicesByType(DeviceType.mobile).length,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _DeviceTypeCard(
                  icon: '💻',
                  title: 'Desktop',
                  count: deviceProvider
                      .getDevicesByType(DeviceType.desktop)
                      .length,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _DeviceTypeCard(
                  icon: '🌐',
                  title: 'Web',
                  count: deviceProvider.getDevicesByType(DeviceType.web).length,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDevicesList(
      BuildContext context, DeviceProvider deviceProvider) {
    if (deviceProvider.isScanning) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.xxxl),
            child: Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: AppSpacing.lg),
                Text('Scanning for devices...'),
              ],
            ),
          ),
        ),
      );
    }

    if (deviceProvider.onlineDevices.isEmpty) {
      return SliverToBoxAdapter(
        child: _buildEmptyState(context),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final device = deviceProvider.onlineDevices[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: DeviceCard(
              device: device,
              onTap: () => _showDeviceOptions(context, device),
            ),
          );
        },
        childCount: deviceProvider.onlineDevices.length,
      ),
    );
  }

  Widget _buildDiscoveryError(BuildContext context, String message) {
    return Container(
      margin: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.none),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: AppOpacity.faint),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.error.withValues(alpha: AppOpacity.quarter)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.body2.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      child: Column(
        children: [
          Icon(
            Icons.devices_other,
            size: AppIconSize.hero,
            color:
                context.palette.textMuted,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No devices found',
            style: AppTextStyles.heading3.copyWith(
              color: context.palette.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Pull to refresh or make sure other devices are running SwiftShare',
            style: AppTextStyles.body2.copyWith(
              color: context.palette.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxl),
          ElevatedButton.icon(
            onPressed: () {
              context.read<DeviceProvider>().refreshDevices();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Scan Again'),
          ),
        ],
      ),
    );
  }

  void _showDeviceOptions(BuildContext context, Device device) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.send),
              title: const Text('Send File'),
              subtitle: Text('Send file to ${device.name}'),
              onTap: () {
                Navigator.pop(context);
                context.read<TransferProvider>().pickAndSendFile(
                      device.id,
                      targetDeviceName: device.name,
                    );
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('Send Folder'),
              subtitle: const Text('Folder sharing is not supported yet'),
              enabled: false,
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Device Info'),
              subtitle: Text('View details about ${device.name}'),
              onTap: () {
                Navigator.pop(context);
                _showDeviceInfo(context, device);
              },
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Block Device'),
              subtitle: Text('Block ${device.name} from connecting'),
              onTap: () {
                Navigator.pop(context);
                _showBlockConfirmation(context, device);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeviceInfo(BuildContext context, Device device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(device.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${device.type.name}'),
            Text('Address: ${device.address}'),
            Text('Capabilities: ${device.capabilities.join(', ')}'),
            Text(
                'Last seen: ${context.read<DeviceProvider>().formatLastSeen(device.lastSeen)}'),
            Text('Status: ${device.isOnline ? 'Online' : 'Offline'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showBlockConfirmation(BuildContext context, Device device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block Device'),
        content: Text('Are you sure you want to block ${device.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<DeviceProvider>().removeDevice(device.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${device.name} has been blocked')),
              );
            },
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }
}

class _NetworkInfoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _NetworkInfoItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: AppIconSize.sm,
              color: context.palette.textSecondary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              title,
              style: AppTextStyles.caption.copyWith(
                color: context.palette.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTextStyles.body1.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _DeviceTypeCard extends StatelessWidget {
  final String icon;
  final String title;
  final int count;
  final Color color;

  const _DeviceTypeCard({
    required this.icon,
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: AppOpacity.subtle),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: color.withValues(alpha: AppOpacity.medium),
        ),
      ),
      child: Column(
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: AppFontSize.xxl),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            count.toString(),
            style: AppTextStyles.heading3.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleAction extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleAction({required this.icon, required this.onTap});

  @override
  State<_CircleAction> createState() => _CircleActionState();
}

class _CircleActionState extends State<_CircleAction> {
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
        duration: AppDurations.instant,
        child: Container(
          width: AppSizes.iconTile,
          height: AppSizes.iconTile,
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
          child: Icon(widget.icon, color: context.palette.textBody, size: AppIconSize.lg),
        ),
      ),
    );
  }
}
