import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

class GradientScaffold extends StatelessWidget {
  const GradientScaffold({
    super.key,
    required this.body,
    this.bottomNavigationBar,
    this.extendBody = false,
  });

  final Widget body;
  final Widget? bottomNavigationBar;
  final bool extendBody;

  @override
  Widget build(BuildContext context) {
    return _GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: body,
        bottomNavigationBar: bottomNavigationBar,
        extendBody: extendBody,
      ),
    );
  }
}

class _GradientBackground extends StatelessWidget {
  const _GradientBackground({required this.child});

  final Widget child;

  static const _neonGlowCenter = Alignment(1, -1);
  static const double _neonGlowRadius = 0.9;
  static const _aquaGlowCenter = Alignment(-1, 0);
  static const double _aquaGlowRadius = 0.8;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(gradient: tokens.background),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: _neonGlowCenter,
                  radius: _neonGlowRadius,
                  colors: [Color(0x3339FF5A), Color(0x0039FF5A)], // neon 20%
                ),
              ),
            ),
          ),
          const IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: _aquaGlowCenter,
                  radius: _aquaGlowRadius,
                  colors: [Color(0x2919D3A0), Color(0x0019D3A0)], // aqua 16%
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
