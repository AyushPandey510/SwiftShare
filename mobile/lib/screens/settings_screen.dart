import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swiftshare_mobile/providers/app_provider.dart';
import 'package:swiftshare_mobile/providers/device_provider.dart';
import 'package:swiftshare_mobile/providers/transfer_provider.dart';
import 'package:swiftshare_mobile/utils/theme.dart';
import 'package:swiftshare_mobile/utils/network_utils.dart';
import 'package:swiftshare_mobile/config/app_config.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDeviceSection(context),
          const SizedBox(height: 24),
          _buildNetworkSection(context),
          const SizedBox(height: 24),
          _buildTransferSection(context),
          const SizedBox(height: 24),
          _buildAppSection(context),
          const SizedBox(height: 24),
          _buildAboutSection(context),
        ],
      ),
    );
  }

  Widget _buildDeviceSection(BuildContext context) {
    return Consumer<DeviceProvider>(
      builder: (context, deviceProvider, child) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Device Settings',
                  style: AppTextStyles.heading3.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                _SettingsItem(
                  icon: Icons.device_hub,
                  title: 'Device Name',
                  subtitle: deviceProvider.devices.isNotEmpty 
                      ? deviceProvider.devices.first.name 
                      : 'Unknown Device',
                  onTap: () => _showDeviceNameDialog(context),
                ),
                _SettingsItem(
                  icon: Icons.wifi,
                  title: 'Local IP Address',
                  subtitle: deviceProvider.localIpAddress.isNotEmpty 
                      ? deviceProvider.localIpAddress 
                      : 'Not connected',
                ),
                _SettingsItem(
                  icon: Icons.qr_code,
                  title: 'Show QR Code',
                  subtitle: 'Display connection QR code',
                  onTap: () => _showQRCode(context),
                ),
                _SettingsItem(
                  icon: Icons.refresh,
                  title: 'Auto-scan for devices',
                  subtitle: 'Automatically discover nearby devices',
                  trailing: Switch(
                    value: true, // TODO: Implement auto-scan setting
                    onChanged: (value) {
                      // TODO: Implement auto-scan toggle
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNetworkSection(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Network Settings',
              style: AppTextStyles.heading3.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<Map<String, dynamic>>(
              future: NetworkUtils.getBackendStatus(),
              builder: (context, snapshot) {
                final isConnected = snapshot.data?['isConnected'] ?? false;
                final backendUrl = snapshot.data?['backendUrl'] ?? AppConfig.backendBaseUrl;
                
                return Column(
                  children: [
                    _SettingsItem(
                      icon: Icons.settings_ethernet,
                      title: 'Backend Server',
                      subtitle: backendUrl,
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isConnected 
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isConnected ? 'Connected' : 'Disconnected',
                          style: TextStyle(
                            fontSize: 12,
                            color: isConnected ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    _SettingsItem(
                      icon: Icons.wifi_find,
                      title: 'Auto-detect Server',
                      subtitle: 'Automatically find backend server',
                      onTap: () => _detectBackendServer(context),
                    ),
                    _SettingsItem(
                      icon: Icons.network_check,
                      title: 'Test Connection',
                      subtitle: 'Test connection to backend',
                      onTap: () => _testBackendConnection(context),
                    ),
                    _SettingsItem(
                      icon: Icons.info_outline,
                      title: 'Network Info',
                      subtitle: 'View network information',
                      onTap: () => _showNetworkInfo(context),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransferSection(BuildContext context) {
    return Consumer<TransferProvider>(
      builder: (context, transferProvider, child) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transfer Settings',
                  style: AppTextStyles.heading3.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                _SettingsItem(
                  icon: Icons.folder,
                  title: 'Download Directory',
                  subtitle: 'Choose where files are saved',
                  onTap: () => _showDownloadDirectoryDialog(context),
                ),
                _SettingsItem(
                  icon: Icons.security,
                  title: 'Enable Encryption',
                  subtitle: 'Encrypt files during transfer',
                  trailing: Switch(
                    value: true, // TODO: Implement encryption setting
                    onChanged: (value) {
                      // TODO: Implement encryption toggle
                    },
                  ),
                ),
                _SettingsItem(
                  icon: Icons.compress,
                  title: 'Auto-compress Large Files',
                  subtitle: 'Compress files larger than 100MB',
                  trailing: Switch(
                    value: false, // TODO: Implement compression setting
                    onChanged: (value) {
                      // TODO: Implement compression toggle
                    },
                  ),
                ),
                _SettingsItem(
                  icon: Icons.delete_sweep,
                  title: 'Clear Transfer History',
                  subtitle: 'Delete all transfer records',
                  onTap: () => _showClearHistoryDialog(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppSection(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'App Settings',
                  style: AppTextStyles.heading3.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                _SettingsItem(
                  icon: Icons.dark_mode,
                  title: 'Dark Mode',
                  subtitle: 'Use dark theme',
                  trailing: Switch(
                    value: appProvider.isDarkMode,
                    onChanged: (value) {
                      appProvider.setDarkMode(value);
                    },
                  ),
                ),
                _SettingsItem(
                  icon: Icons.notifications,
                  title: 'Transfer Notifications',
                  subtitle: 'Show notifications for transfers',
                  trailing: Switch(
                    value: true, // TODO: Implement notification setting
                    onChanged: (value) {
                      // TODO: Implement notification toggle
                    },
                  ),
                ),
                _SettingsItem(
                  icon: Icons.speed,
                  title: 'Show Transfer Speed',
                  subtitle: 'Display real-time transfer speeds',
                  trailing: Switch(
                    value: true, // TODO: Implement speed display setting
                    onChanged: (value) {
                      // TODO: Implement speed display toggle
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About',
              style: AppTextStyles.heading3.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _SettingsItem(
              icon: Icons.info,
              title: 'Version',
              subtitle: '1.0.0',
            ),
            _SettingsItem(
              icon: Icons.description,
              title: 'Privacy Policy',
              subtitle: 'Read our privacy policy',
              onTap: () => _showPrivacyPolicy(context),
            ),
            _SettingsItem(
              icon: Icons.description,
              title: 'Terms of Service',
              subtitle: 'Read our terms of service',
              onTap: () => _showTermsOfService(context),
            ),
            _SettingsItem(
              icon: Icons.bug_report,
              title: 'Report Bug',
              subtitle: 'Report a bug or issue',
              onTap: () => _showBugReport(context),
            ),
            _SettingsItem(
              icon: Icons.feedback,
              title: 'Send Feedback',
              subtitle: 'Send us your feedback',
              onTap: () => _showFeedback(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeviceNameDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Device Name'),
        content: TextField(
          decoration: const InputDecoration(
            labelText: 'Enter device name',
            hintText: 'My Device',
          ),
          controller: TextEditingController(
            text: context.read<DeviceProvider>().devices.isNotEmpty 
                ? context.read<DeviceProvider>().devices.first.name 
                : '',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement device name update
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Device name updated')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showQRCode(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Connection QR Code'),
        content: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text(
              'QR Code\nPlaceholder',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
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

  void _showDownloadDirectoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download Directory'),
        content: const Text('Choose where downloaded files should be saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement directory picker
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Download directory updated')),
              );
            },
            child: const Text('Choose'),
          ),
        ],
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Transfer History'),
        content: const Text(
          'Are you sure you want to clear all transfer history? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<TransferProvider>().clearCompletedTransfers();
              context.read<TransferProvider>().clearFailedTransfers();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Transfer history cleared')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'SwiftShare respects your privacy. We do not collect, store, or transmit any personal data. All file transfers are performed locally between devices on your network.',
          ),
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

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'By using SwiftShare, you agree to use this application responsibly and in compliance with all applicable laws. You are responsible for the content you share.',
          ),
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

  void _showBugReport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Bug'),
        content: const Text('Bug reporting feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showFeedback(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Feedback'),
        content: const Text('Feedback feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showBackendConfigDialog(BuildContext context) {
    final controller = TextEditingController(text: AppConfig.backendBaseUrl);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backend Server Configuration'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the backend server URL:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Server URL',
                hintText: 'http://192.168.1.100:8080',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement backend URL update
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Backend URL updated to: ${controller.text}')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _detectBackendServer(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        title: Text('Detecting Backend Server'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Scanning network for backend server...'),
          ],
        ),
      ),
    );

    try {
      final success = await NetworkUtils.autoConfigureBackend();
      Navigator.pop(context);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backend server configured: ${AppConfig.backendBaseUrl}'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Refresh the settings screen to show updated status
        setState(() {});
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('No Backend Server Found'),
            content: const Text(
              'No backend server was detected on your network. '
              'Please make sure the backend is running and try again. '
              'You can also manually configure the backend URL in the settings.'
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error detecting server: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _testBackendConnection(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        title: Text('Testing Connection'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Testing connection to backend...'),
          ],
        ),
      ),
    );

    try {
      final isConnected = await NetworkUtils.testBackendConnection();
      Navigator.pop(context);
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(isConnected ? 'Connection Successful' : 'Connection Failed'),
          content: Text(
            isConnected 
              ? 'Successfully connected to the backend server.'
              : 'Failed to connect to the backend server. Please check your network settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error testing connection: $e')),
      );
    }
  }

  void _showNetworkInfo(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        title: Text('Loading Network Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Gathering network information...'),
          ],
        ),
      ),
    );

    try {
      final networkInfo = await NetworkUtils.getNetworkInfo();
      Navigator.pop(context);
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Network Information'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _NetworkInfoItem('Local IP', networkInfo['localIp'] ?? 'Unknown'),
                _NetworkInfoItem('Gateway IP', networkInfo['gatewayIp'] ?? 'Unknown'),
                _NetworkInfoItem('Backend URL', networkInfo['backendUrl'] ?? 'Unknown'),
                _NetworkInfoItem('Connected', networkInfo['isConnected'] ?? 'Unknown'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting network info: $e')),
      );
    }
  }
}

class _NetworkInfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _NetworkInfoItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: AppTextStyles.body1.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.caption.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
} 