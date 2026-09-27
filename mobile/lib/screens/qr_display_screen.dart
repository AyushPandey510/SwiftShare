import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:swiftshare_mobile/utils/theme.dart';

class QRDisplayScreen extends StatefulWidget {
  const QRDisplayScreen({super.key});

  @override
  State<QRDisplayScreen> createState() => _QRDisplayScreenState();
}

class _QRDisplayScreenState extends State<QRDisplayScreen> {
  String _qrData = 'swiftshare://test-device-123/192.168.1.100:8080';
  bool _isSharing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.background,
      appBar: AppBar(
        title: const Text(
          'My QR Code',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _isSharing ? null : _shareQRCode,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          children: [
            // QR Code Container
            Container(
              padding: const EdgeInsets.all(AppSpacing.xxxl),
              decoration: BoxDecoration(
                color: context.palette.surface,
                borderRadius: BorderRadius.circular(AppRadius.xxl),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: AppOpacity.subtle),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: AppOpacity.medium),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  // SwiftShare Logo
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: context.isDark ? AppColors.primary : null,
                      gradient: context.isDark
                          ? null
                          : const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primary,
                                AppColors.secondary,
                              ],
                            ),
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                    ),
                    child: const Icon(
                      Icons.devices_other,
                      size: AppIconSize.xxl,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  // QR Code
                  QrImageView(
                    data: _qrData,
                    version: QrVersions.auto,
                    size: 200.0,
                    backgroundColor: Colors.white,
                    dataModuleStyle: const QrDataModuleStyle(
                      color: AppColors.primary,
                    ),
                    eyeStyle: const QrEyeStyle(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  // Device Info
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: AppOpacity.subtle),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: AppOpacity.medium),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Device Information',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: AppFontSize.md,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _buildInfoRow('Device ID', 'test-device-123'),
                        _buildInfoRow('IP Address', '192.168.1.100'),
                        _buildInfoRow('Port', '8080'),
                        _buildInfoRow('Status', 'Online'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),
            // Instructions
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: context.palette.surfaceMuted,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.primary,
                        size: AppIconSize.lg,
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Text(
                        'How to connect',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: AppFontSize.md,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildInstructionStep(
                    1,
                    'Open SwiftShare on another device',
                  ),
                  _buildInstructionStep(
                    2,
                    'Tap "Scan QR" in the Quick Actions',
                  ),
                  _buildInstructionStep(
                    3,
                    'Point the camera at this QR code',
                  ),
                  _buildInstructionStep(
                    4,
                    'Tap "Connect" when prompted',
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            // Test QR Code Button
            ElevatedButton.icon(
              onPressed: _generateTestQR,
              icon: const Icon(Icons.qr_code),
              label: const Text('Generate Test QR'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: context.palette.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(int step, String instruction) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Center(
              child: Text(
                step.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: AppFontSize.xs,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              instruction,
              style: const TextStyle(
                fontSize: AppFontSize.sm,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _shareQRCode() {
    setState(() {
      _isSharing = true;
    });

    // Simulate sharing
    Future.delayed(AppDurations.pulse, () {
      if (!mounted) return;
      setState(() {
        _isSharing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('QR code shared!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      );
    });
  }

  void _generateTestQR() {
    final testData = [
      'swiftshare://test-device-123/192.168.1.100:8080',
      'swiftshare://mobile-device/10.0.0.50:9090',
      'swiftshare://desktop-pc/172.16.1.200:7070',
    ];

    setState(() {
      _qrData = testData[DateTime.now().millisecond % testData.length];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Generated test QR: $_qrData'),
        backgroundColor: AppColors.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }
}
