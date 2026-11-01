import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

// Plays the splash Lottie once, or shows its last frame when play is false.
class SplashAnimation extends StatefulWidget {
  const SplashAnimation({
    super.key,
    required this.play,
    required this.onLoaded,
    required this.onFinished,
    required this.onFailed,
  });

  final bool play;
  final VoidCallback onLoaded;
  final VoidCallback onFinished;
  final VoidCallback onFailed;

  @override
  State<SplashAnimation> createState() => _SplashAnimationState();
}

class _SplashAnimationState extends State<SplashAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this)
    ..addStatusListener((status) {
      if (status == AnimationStatus.completed) widget.onFinished();
    });
  bool _failed = false;

  static const _asset = 'assets/json/splash.json';
  static const double _widthFraction = 0.7;
  static const double _heightFraction = 0.45;
  static const double _maxSize = 360;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleLoaded(LottieComposition composition) {
    _controller.duration = composition.duration;
    if (widget.play) {
      _controller.forward();
    } else {
      _controller.value = 1;
    }
    widget.onLoaded();
  }

  // errorBuilder runs during build, so the report waits for the frame.
  void _handleFailed() {
    if (_failed) return;
    _failed = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.onFailed());
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final size = [
      screen.width * _widthFraction,
      screen.height * _heightFraction,
      _maxSize,
    ].reduce(min);
    return Lottie.asset(
      _asset,
      controller: _controller,
      width: size,
      height: size,
      fit: BoxFit.contain,
      onLoaded: _handleLoaded,
      errorBuilder: (context, error, stackTrace) {
        _handleFailed();
        return SizedBox.square(dimension: size);
      },
    );
  }
}
