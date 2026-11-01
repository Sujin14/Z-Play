import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/app/app_name.dart';
import '../../../core/theme/app_tokens.dart';

// The app name under the splash Lottie. It is laid out from the first frame
// and only fades and slides, so the Lottie above it never moves.
class SplashWordmark extends StatefulWidget {
  const SplashWordmark({super.key});

  @override
  State<SplashWordmark> createState() => _SplashWordmarkState();
}

class _SplashWordmarkState extends State<SplashWordmark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: _fadeDuration);
  late final CurvedAnimation _curved =
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
  Timer? _delay;

  static const _fadeDelay = Duration(milliseconds: 300);
  static const _fadeDuration = Duration(milliseconds: 600);
  static const double _slide = 8;
  static const double _fontSize = 28;
  static const double _letterSpacing = 0.04 * _fontSize;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller.value > 0 || _delay != null) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else {
      _delay = Timer(_fadeDelay, _controller.forward);
    }
  }

  @override
  void dispose() {
    _delay?.cancel();
    _curved.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curved,
      builder: (context, child) => Opacity(
        opacity: _curved.value,
        child: Transform.translate(
          offset: Offset(0, _slide * (1 - _curved.value)),
          child: child,
        ),
      ),
      // The splash sits on the dark gradient in both themes, so the name
      // always uses the dark theme's text color.
      child: Text(
        appName,
        maxLines: 1,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontSize: _fontSize,
              fontWeight: FontWeight.w800,
              letterSpacing: _letterSpacing,
              color: AppTokens.dark.text,
            ),
      ),
    );
  }
}
