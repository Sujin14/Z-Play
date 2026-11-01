import 'package:flutter/material.dart';

import '../app/app_name.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

class Wordmark extends StatelessWidget {
  const Wordmark({super.key, this.fontSize = _defaultFontSize});

  final double fontSize;

  static const double _defaultFontSize = 24;
  static const double _glowAlpha = 0.5;
  static const double _glowBlur = 0.5;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      appName,
      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontSize: fontSize,
            letterSpacing: 0,
            color: dark ? AppColors.neon : tokens.accentText,
            shadows: dark
                ? [
                    Shadow(
                        color: AppColors.neon.withValues(alpha: _glowAlpha),
                        blurRadius: fontSize * _glowBlur)
                  ]
                : null,
          ),
    );
  }
}
