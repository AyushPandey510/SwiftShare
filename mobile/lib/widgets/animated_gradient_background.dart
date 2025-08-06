import 'package:flutter/material.dart';
import 'dart:math';

class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  const AnimatedGradientBackground({Key? key, required this.child}) : super(key: key);

  @override
  State<AnimatedGradientBackground> createState() => _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final List<List<Color>> _gradients = [
    [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFF06B6D4)], // Indigo, Purple, Cyan
    [Color(0xFFF59E0B), Color(0xFFEF4444), Color(0xFF6366F1)], // Amber, Red, Indigo
    [Color(0xFF10B981), Color(0xFF06B6D4), Color(0xFF8B5CF6)], // Green, Cyan, Purple
    [Color(0xFFF472B6), Color(0xFF6366F1), Color(0xFF06B6D4)], // Pink, Indigo, Cyan
  ];
  int _currentGradient = 0;
  int _nextGradient = 1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
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
                          Colors.white.withOpacity(0.12),
                          Colors.black.withOpacity(0.08),
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