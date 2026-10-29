import 'package:flutter/material.dart';

import '../theme/app_sizes.dart';
import '../theme/app_tokens.dart';

class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? color;

  static const double _iconSize = 24;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    return Material(
      color: tokens.card,
      shape: CircleBorder(side: BorderSide(color: tokens.line)),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        iconSize: _iconSize,
        constraints: const BoxConstraints.tightFor(
            width: AppSizes.roundButton, height: AppSizes.roundButton),
        icon: Icon(icon, color: color),
      ),
    );
  }
}
