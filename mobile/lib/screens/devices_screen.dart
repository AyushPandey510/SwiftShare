import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swiftshare_mobile/providers/device_provider.dart';
import 'package:swiftshare_mobile/utils/theme.dart';
import 'package:swiftshare_mobile/widgets/device_card.dart';

class DevicesScreen extends StatelessWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Devices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              // TODO: Implement QR scanner
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('QR scanner coming soon!')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<DeviceProvider>().refreshDevices();
            },
          ),
        ],
      ),
      body: Consumer<DeviceProvider>(
        builder: (context, deviceProvider, child) {
          return RefreshIndicator(
            onRefresh: () => deviceProvider.refreshDevices(),
            child: CustomScrollView(
              slivers: [
                // Network Info
                SliverToBoxAdapter(
                  child: _buildNetworkInfo(context, deviceProvider),
                ),
                
                // Device Categories
                SliverToBoxAdapter(
                  child: _buildDeviceCategories(context, deviceProvider),
                ),
                
                // Devices List
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: _buildDevicesList(context, deviceProvider),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNetworkInfo(BuildContext context, DeviceProvider deviceProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.wifi,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Network Status',
                style: AppTextStyles.heading3.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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

  Widget _buildDeviceCategories(BuildContext context, DeviceProvider deviceProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Device Types',
            style: AppTextStyles.heading3.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _DeviceTypeCard(
                  icon: '📱',
                  title: 'Mobile',
                  count: deviceProvider.getDevicesByType(DeviceType.mobile).length,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DeviceTypeCard(
                  icon: '💻',
                  title: 'Desktop',
                  count: deviceProvider.getDevicesByType(DeviceType.desktop).length,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 12),
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

  Widget _buildDevicesList(BuildContext context, DeviceProvider deviceProvider) {
    if (deviceProvider.isScanning) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
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
            padding: const EdgeInsets.only(bottom: 12.0),
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

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.devices_other,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No devices found',
            style: AppTextStyles.heading3.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pull to refresh or make sure other devices are running SwiftShare',
            style: AppTextStyles.body2.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
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
                // TODO: Implement file sending
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
            Text('Last seen: ${context.read<DeviceProvider>().formatLastSeen(device.lastSeen)}'),
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
              size: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 4),
            Text(
              title,
              style: AppTextStyles.caption.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
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