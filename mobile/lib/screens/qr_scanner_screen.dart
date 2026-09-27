import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:swiftshare_mobile/screens/access_file_screen.dart';
import 'package:swiftshare_mobile/services/share_api_service.dart';
import 'package:swiftshare_mobile/utils/theme.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen>
    with TickerProviderStateMixin {
  MobileScannerController controller = MobileScannerController();
  bool _isScanning = true;
  bool _hasPermission = false;
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppDurations.pulse,
      vsync: this,
    )..repeat();
    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _checkCameraPermission();
  }

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      setState(() {
        _hasPermission = true;
        _isLoading = false;
      });
    } else {
      final result = await Permission.camera.request();
      setState(() {
        _hasPermission = result.isGranted;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Scan QR Code',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isScanning ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
            onPressed: _hasPermission
                ? () {
                    setState(() {
                      _isScanning = !_isScanning;
                      if (_isScanning) {
                        controller.start();
                      } else {
                        controller.stop();
                      }
                    });
                  }
                : null,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : !_hasPermission
              ? _buildPermissionDenied()
              : _buildScanner(),
    );
  }

  Widget _buildPermissionDenied() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: AppOpacity.medium),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: const Icon(
                Icons.camera_alt_outlined,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            const Text(
              'Camera Permission Required',
              style: TextStyle(
                color: Colors.white,
                fontSize: AppFontSize.xxl,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'SwiftShare needs camera access to scan QR codes.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: AppFontSize.md,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxxl),
            ElevatedButton.icon(
              onPressed: _checkCameraPermission,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Grant Permission'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
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

  Widget _buildScanner() {
    return Stack(
      children: [
        MobileScanner(
          controller: controller,
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              if (barcode.rawValue != null) {
                _handleQRCode(barcode.rawValue!);
                break;
              }
            }
          },
          errorBuilder: (context, error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: AppOpacity.medium),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: const Icon(
                      Icons.error_outline,
                      size: AppIconSize.xxl,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Text(
                    'Camera Error',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppFontSize.xl,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    error.errorDetails?.message ?? 'Unknown error',
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  ElevatedButton(
                    onPressed: () {
                      controller.start();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          },
        ),
        _buildScanOverlay(),
      ],
    );
  }

  Widget _buildScanOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: AppOpacity.high),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Position QR code within the frame',
              style: TextStyle(
                color: Colors.white,
                fontSize: AppFontSize.md,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),
            Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 3),
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: Stack(
                children: [
                  // Animated scan line
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: AnimatedBuilder(
                      animation: _scanAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _scanAnimation.value * 280),
                          child: Container(
                            height: 2,
                            decoration: BoxDecoration(
                              color:
                                  context.isDark ? AppColors.primary : null,
                              gradient: context.isDark
                                  ? null
                                  : const LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        AppColors.primary,
                                        Colors.transparent,
                                      ],
                                    ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Corner indicators
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      width: AppSizes.iconTile,
                      height: AppSizes.iconTile,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: AppColors.primary, width: 4),
                          left: BorderSide(color: AppColors.primary, width: 4),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: AppSizes.iconTile,
                      height: AppSizes.iconTile,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: AppColors.primary, width: 4),
                          right: BorderSide(color: AppColors.primary, width: 4),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      width: AppSizes.iconTile,
                      height: AppSizes.iconTile,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom:
                              BorderSide(color: AppColors.primary, width: 4),
                          left: BorderSide(color: AppColors.primary, width: 4),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: AppSizes.iconTile,
                      height: AppSizes.iconTile,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom:
                              BorderSide(color: AppColors.primary, width: 4),
                          right: BorderSide(color: AppColors.primary, width: 4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.huge),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: AppOpacity.overlay),
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: const Text(
                'Scanning for SwiftShare devices...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: AppFontSize.sm,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleQRCode(String qrData) {
    // Stop scanning
    controller.stop();
    setState(() {
      _isScanning = false;
    });

    // Parse QR data and handle connection
    _processQRData(qrData);
  }

  void _processQRData(String qrData) {
    try {
      final data = qrData.trim();
      final fileCode = ShareApiService.extractCode(data);
      if (fileCode != null) {
        _openSharedFile(fileCode);
        return;
      }

      if (data.startsWith('swiftshare://')) {
        _handleSwiftShareConnection(data);
      } else if (data.startsWith('http://') || data.startsWith('https://')) {
        _handleHttpConnection(data);
      } else {
        _showQRResult('Text', data);
      }
    } catch (e) {
      _showQRResult('Error', 'Invalid QR code format: $e');
    }
  }

  void _handleSwiftShareConnection(String url) {
    try {
      final uri = Uri.parse(url);
      final deviceId = uri.host;
      final port = uri.port;

      _showQRResult('SwiftShare Device', 'Device ID: $deviceId\nPort: $port');
    } catch (e) {
      _showQRResult('Error', 'Invalid SwiftShare URL: $e');
    }
  }

  void _handleHttpConnection(String url) {
    _showQRResult('HTTP URL', url);
  }

  void _openSharedFile(String code) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AccessFileScreen(initialCode: code),
      ),
    );
  }

  void _showQRResult(String title, String content) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        title: Row(
          children: [
            Icon(
              title == 'Error' ? Icons.error : Icons.qr_code,
              color: title == 'Error' ? AppColors.error : AppColors.primary,
            ),
            const SizedBox(width: AppSpacing.md),
            Text(title),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: AppOpacity.subtle),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                content,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Would you like to connect to this device?',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              _connectToDevice(content);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }

  void _connectToDevice(String deviceInfo) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Connecting to device: $deviceInfo'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    controller.dispose();
    super.dispose();
  }
}
