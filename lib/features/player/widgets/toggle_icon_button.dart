import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';

class ToggleIconButton extends StatelessWidget {
  const ToggleIconButton({
    super.key,
    required this.icon,
    required this.active,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final bool active;
  final String tooltip;
  final VoidCallback onPressed;

  static const double _minWidth = 48;
  static const double _minHeight = 56;
  static const double _iconSize = 26;
  static const double _dot = 5;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    final color = active ? tokens.accentText : tokens.text2;
    return Semantics(
      toggled: active,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        constraints:
            const BoxConstraints(minWidth: _minWidth, minHeight: _minHeight),
        icon: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: _iconSize, color: color),
            const SizedBox(height: 4),
            // Always laid out, so toggling doesn't shift the icon.
            Container(
              width: _dot,
              height: _dot,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active ? tokens.accentText : Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
