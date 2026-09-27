import 'package:flutter/material.dart';
import 'dart:math';

import '../utils/theme.dart';

class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  const AnimatedGradientBackground({super.key, required this.child});

  @override
  State<AnimatedGradientBackground> createState() => _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final List<List<Color>> _gradients = [
    [AppColors.primary, AppColors.secondary, AppColors.accent], // Indigo, Purple, Cyan
    [AppColors.warning, AppColors.error, AppColors.primary], // Amber, Red, Indigo
    [AppColors.success, AppColors.accent, AppColors.secondary], // Green, Cyan, Purple
    [AppColors.pink, AppColors.primary, AppColors.accent], // Pink, Indigo, Cyan
  ];
  int _currentGradient = 0;
  int _nextGradient = 1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.ambient,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _currentGradient = _nextGradient;
            _nextGradient = (_nextGradient + 1) % _gradients.length;
          });
          _controller.forward(from: 0);
        }
      });
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Dark mode: plain solid background, no animated gradient.
    if (context.isDark) {
      return ColoredBox(color: context.palette.background, child: widget.child);
    }
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final colors = List.generate(3, (i) =>
          Color.lerp(_gradients[_currentGradient][i], _gradients[_nextGradient][i], _animation.value)!
        );
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
          ),
          child: Stack(
            children: [
              // 3D radial overlay
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(
                          0.5 + 0.2 * sin(_controller.value * 2 * pi),
                          0.5 + 0.2 * cos(_controller.value * 2 * pi),
                        ),
                        radius: 0.8,
                        colors: [
                          Colors.white.withValues(alpha: AppOpacity.subtle),
                          Colors.black.withValues(alpha: AppOpacity.faint),
                        ],
                        stops: const [0.0, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
              // Main content
              widget.child,
            ],
          ),
        );
      },
    );
  }
} 