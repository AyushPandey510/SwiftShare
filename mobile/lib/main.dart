import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:swiftshare_mobile/providers/app_provider.dart';
import 'package:swiftshare_mobile/providers/share_provider.dart';
import 'package:swiftshare_mobile/providers/transfer_provider.dart';
import 'package:swiftshare_mobile/providers/device_provider.dart';
import 'package:swiftshare_mobile/screens/share_screen.dart';
import 'package:swiftshare_mobile/screens/transfers_screen.dart';
import 'package:swiftshare_mobile/screens/devices_screen.dart';
import 'package:swiftshare_mobile/screens/settings_screen.dart';
import 'package:swiftshare_mobile/utils/theme.dart';
import 'package:swiftshare_mobile/utils/network_utils.dart';
import 'package:swiftshare_mobile/config/app_config.dart';

void main() {
  final binding = WidgetsFlutterBinding.ensureInitialized();

  // Keep the native splash on screen until the splash logo is decoded, so the
  // first Flutter frame already shows it (no blank or half-drawn frame).
  // SplashScreen calls allowFirstFrame() once the image is cached.
  binding.deferFirstFrame();

  // Not awaited: nothing here should delay the first frame.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const SwiftShareApp());
}

class SwiftShareApp extends StatelessWidget {
  const SwiftShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => ShareProvider()),
        ChangeNotifierProvider(create: (_) => TransferProvider()),
        ChangeNotifierProvider(create: (_) => DeviceProvider()),
      ],
      child: Consumer<AppProvider>(
        builder: (context, appProvider, _) => MaterialApp(
          title: 'SwiftShare',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          // Was hard-coded to ThemeMode.system, so the Settings switch did
          // nothing. Now driven by the user's choice (System / Light / Dark).
          themeMode: appProvider.themeMode,
          home: const SplashScreen(),
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            final bool dark = Theme.of(context).brightness == Brightness.dark;
            // Status bar and Android nav bar icons follow the theme too.
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: (dark
                      ? SystemUiOverlayStyle.light
                      : SystemUiOverlayStyle.dark)
                  .copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: context.palette.navBar,
                systemNavigationBarIconBrightness:
                    dark ? Brightness.light : Brightness.dark,
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
        ),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// Splash logo. Size and position must match the native Android splash
// (res/drawable-*/splash_logo.png and splash_icon.png): 140dp, screen centre.
const String _splashLogoAsset = 'assets/images/splash_logo.png';
const double _logoSize = 140;
// Shortest time the splash stays up, so the spinner never just flickers.
const Duration _minSplashTime = Duration(milliseconds: 600);
const double _ringStroke = _logoSize * 24 / 488;
const double _ringBox = _logoSize * (2 * 220 + 24) / 488;

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  bool _firstFrameReleased = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animationController.repeat(reverse: true);

    _initializeApp();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_firstFrameReleased) return;
    _firstFrameReleased = true;
    // Decode the logo, then let Flutter paint. A 1 s cap makes sure a slow
    // or failed decode can never leave the user stuck on the native splash.
    precacheImage(const AssetImage(_splashLogoAsset), context)
        .timeout(const Duration(seconds: 1), onTimeout: () {})
        .whenComplete(WidgetsBinding.instance.allowFirstFrame);
  }

  Future<void> _initializeApp() async {
    // Loaded here instead of before runApp(), so it no longer delays startup.
    await AppConfig.loadSavedBackendUrl().catchError((_) {});
    await Future.wait([
      Future<void>.delayed(_minSplashTime),
      NetworkUtils.autoConfigureBackend().catchError((_) => false),
    ]);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MainScreen()),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // Logo is pinned to the exact screen centre, like the native splash,
      // so the handoff from Android's splash to Flutter doesn't move it.
      body: Stack(
        children: [
          Center(
            child: ScaleTransition(
              scale: Tween<double>(begin: 1.0, end: 1.04).animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: Curves.easeInOut,
                ),
              ),
              child: SizedBox(
                width: _logoSize,
                height: _logoSize,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Spinner runs on the logo's ring (ring r=220, stroke 24
                    // in a 488-unit viewBox). The track is the ring colour, and
                    // the logo is drawn on top so the device icons stay visible.
                    SizedBox(
                      width: _ringBox,
                      height: _ringBox,
                      child: const CircularProgressIndicator(
                        strokeWidth: _ringStroke,
                        strokeCap: StrokeCap.round,
                        backgroundColor: Color(0xFFEEF2FF),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                    Image.asset(
                      _splashLogoAsset,
                      width: _logoSize,
                      height: _logoSize,
                      semanticLabel: 'SwiftShare logo',
                    ),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Transform.translate(
              offset: const Offset(0, _logoSize / 2 + 44),
              child: Text.rich(
                TextSpan(
                  children: const [
                    TextSpan(
                      text: 'Swift',
                      style: TextStyle(color: Color(0xFF1E1B4B)),
                    ),
                    TextSpan(
                      text: 'Share',
                      style: TextStyle(color: Color(0xFF4F46E5)),
                    ),
                  ],
                  style: AppTextStyles.heading2.copyWith(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ShareScreen(),
    const TransfersScreen(),
    const DevicesScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _SwiftShareBottomBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          HapticFeedback.selectionClick();
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class _SwiftShareBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _SwiftShareBottomBar({
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    _NavSpec(Icons.upload_file_outlined, Icons.upload_file, 'Share'),
    _NavSpec(Icons.swap_vert_outlined, Icons.swap_vert, 'Transfers'),
    _NavSpec(Icons.desktop_windows_outlined, Icons.desktop_windows, 'Devices'),
    _NavSpec(Icons.settings_outlined, Icons.settings, 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.palette.navBar,
        border: Border(
          top: BorderSide(color: context.palette.border),
        ),
        boxShadow: [
          BoxShadow(
            color: context.palette.shadow,
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
          color: context.palette.navBar,
          child: Row(
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              return Expanded(
                child: _BottomBarItem(
                  spec: item,
                  selected: currentIndex == index,
                  onTap: () => onTap(index),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _BottomBarItem extends StatefulWidget {
  final _NavSpec spec;
  final bool selected;
  final VoidCallback onTap;

  const _BottomBarItem({
    required this.spec,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_BottomBarItem> createState() => _BottomBarItemState();
}

class _BottomBarItemState extends State<_BottomBarItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.selected ? AppColors.primary : context.palette.textMuted;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: widget.selected ? context.palette.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: widget.selected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.selected ? widget.spec.activeIcon : widget.spec.icon,
                size: 22,
                color: color,
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                style: AppTextStyles.caption.copyWith(
                  color: color,
                  fontSize: 11,
                  fontWeight:
                      widget.selected ? FontWeight.w800 : FontWeight.w600,
                ),
                child: Text(widget.spec.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavSpec {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavSpec(this.icon, this.activeIcon, this.label);
}
