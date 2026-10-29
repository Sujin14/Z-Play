import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';
import 'pill_button_label.dart';

class GhostButton extends StatelessWidget {
  const GhostButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = false,
    this.accent = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;
  final bool accent;

  static const double _disabledOpacity = 0.5;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    return Opacity(
      opacity: onPressed != null ? 1 : _disabledOpacity,
      child: Material(
        color: tokens.card,
        shape: StadiumBorder(side: BorderSide(color: tokens.line)),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onPressed,
          child: PillButtonLabel(
            label: label,
            icon: icon,
            expand: expand,
            color: accent ? tokens.accentText : tokens.text,
          ),
        ),
      ),
    );
  }
}
