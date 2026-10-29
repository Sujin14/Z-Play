import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

// Visual only: the surrounding row handles the tap.
class GradientCheckbox extends StatelessWidget {
  const GradientCheckbox({super.key, required this.checked});

  final bool checked;

  static const double _size = 24;
  static const _animation = Duration(milliseconds: 150);
  static const double _cornerFactor = 0.3;
  static const double _checkFactor = 0.75;
  static const double _borderAlpha = 0.6;
  static const double _borderWidth = 1.5;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    return AnimatedContainer(
      duration: _animation,
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        gradient: checked ? AppColors.action : null,
        borderRadius: BorderRadius.circular(_size * _cornerFactor),
        border: checked
            ? null
            : Border.all(
                color: tokens.text2.withValues(alpha: _borderAlpha),
                width: _borderWidth),
      ),
      child: checked
          ? Icon(Icons.check_rounded,
              size: _size * _checkFactor, color: AppColors.onAccent)
          : null,
    );
  }
}
