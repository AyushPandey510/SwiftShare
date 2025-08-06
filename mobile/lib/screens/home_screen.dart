import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swiftshare_mobile/providers/device_provider.dart';
import 'package:swiftshare_mobile/providers/transfer_provider.dart';
import 'package:swiftshare_mobile/utils/theme.dart';
import 'package:swiftshare_mobile/widgets/device_card.dart';
import 'package:swiftshare_mobile/widgets/quick_actions.dart';
import 'package:swiftshare_mobile/widgets/transfer_summary.dart';
import 'package:swiftshare_mobile/widgets/device_skeleton.dart';
import 'package:swiftshare_mobile/screens/qr_scanner_screen.dart';
import 'package:swiftshare_mobile/screens/qr_display_screen.dart';
import 'package:swiftshare_mobile/widgets/animated_gradient_background.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    'SwiftShare',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  background: Container(
                    color: Colors.transparent,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.qr_code_scanner),
                    onPressed: () => _showQRScanner(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.qr_code),
                    onPressed: () => _showQRDisplay(context),
                  ),
                ],
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quick Actions
                      const QuickActionsWidget(),
                      const SizedBox(height: 24),
                      // Transfer Summary
                      const TransferSummaryWidget(),
                      const SizedBox(height: 24),
                      // Available Devices
                      _buildDevicesSection(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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

  void _showQRDisplay(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const QRDisplayScreen(),
      ),
    );
  }

  Widget _buildDevicesSection(BuildContext context) {
    return Consumer<DeviceProvider>(
      builder: (context, deviceProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Available Devices',
                  style: AppTextStyles.heading3.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: Icon(
                      deviceProvider.isScanning 
                          ? Icons.refresh 
                          : Icons.refresh_outlined,
                      color: AppColors.primary,
                    ),
                    onPressed: deviceProvider.isScanning 
                        ? null 
                        : () => deviceProvider.refreshDevices(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (deviceProvider.isScanning)
              const DeviceListSkeleton(count: 3)
            else if (deviceProvider.onlineDevices.isEmpty)
              _buildEmptyState(context)
            else
              _buildDevicesList(deviceProvider),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.devices_other,
              size: 40,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No devices found',
            style: AppTextStyles.heading3.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Make sure other devices are running SwiftShare and on the same network',
            style: AppTextStyles.body2.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              context.read<DeviceProvider>().refreshDevices();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Scan Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDevicesList(DeviceProvider deviceProvider) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.success.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Text(
            '${deviceProvider.onlineDevices.length} device${deviceProvider.onlineDevices.length == 1 ? '' : 's'} found',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: deviceProvider.onlineDevices.length,
          itemBuilder: (context, index) {
            final device = deviceProvider.onlineDevices[index];
            return DeviceCard(
              device: device,
              onTap: () {
                _showDeviceOptions(context, device);
              },
            );
          },
        ),
      ],
    );
  }

  void _showDeviceOptions(BuildContext context, Device device) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.send),
              title: const Text('Send File'),
              subtitle: Text('Send file to ${device.name}'),
              onTap: () {
                Navigator.pop(context);
                context.read<TransferProvider>().pickAndSendFile(device.name);
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('Send Folder'),
              subtitle: Text('Send folder to ${device.name}'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement folder sending
              },
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
            Text('Last seen: ${context.read<DeviceProvider>().formatLastSeen(device.lastSeen)}'),
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
} 