import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

// Drawn in code instead of from the logo image, so there is no background
// box.
class LogoMark extends StatelessWidget {
  const LogoMark({super.key, this.size = _defaultSize});

  final double size;

  static const double _defaultSize = 96;
  // Everything scales with size so the mark keeps its proportions.
  static const double _glowBlur = 0.25;
  static const double _border = 0.03;
  static const double _letter = 0.48;
  static const double _letterGlow = 0.12;
  static const double _glowAlpha = 0.45;
  static const double _fillAlpha = 0.6;
  static const double _lightFillAlpha = 0.5;
  static const double _letterGlowAlpha = 0.6;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final color = dark ? AppColors.neon : tokens.accentText;
    final glow = [
      if (dark)
        BoxShadow(
            color: AppColors.neon.withValues(alpha: _glowAlpha),
            blurRadius: size * _glowBlur),
    ];
    final mark = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: dark
            ? AppColors.dBase.withValues(alpha: _fillAlpha)
            : Colors.white.withValues(alpha: _lightFillAlpha),
        border: Border.all(color: color, width: size * _border),
        boxShadow: glow,
      ),
      alignment: Alignment.center,
      child: Text(
        'Z',
        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontSize: size * _letter,
              height: 1,
              color: color,
              shadows: dark
                  ? [
                      Shadow(
                          color: AppColors.neon
                              .withValues(alpha: _letterGlowAlpha),
                          blurRadius: size * _letterGlow)
                    ]
                  : null,
            ),
      ),
    );
    return ExcludeSemantics(child: mark);
  }
}
