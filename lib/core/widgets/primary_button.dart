import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_tokens.dart';
import 'pill_button_label.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = false,
    this.destructive = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;
  final bool destructive;

  static const double _disabledOpacity = 0.5;
  static const double _glowAlpha = 0.3;
  static const double _glowBlur = 18;
  static const Offset _glowOffset = Offset(0, 6);

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    final enabled = onPressed != null;
    final glow = destructive ? tokens.heart : AppColors.neon;
    // Dark text on light-mode coral is only 3.9:1; white reads better there.
    final light = Theme.of(context).brightness == Brightness.light;
    final labelColor = destructive && light ? Colors.white : AppColors.onAccent;
    return Opacity(
      opacity: enabled ? 1 : _disabledOpacity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: destructive ? null : AppColors.action,
          color: destructive ? tokens.heart : null,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          boxShadow: enabled
              ? [
                  BoxShadow(
                      color: glow.withValues(alpha: _glowAlpha),
                      blurRadius: _glowBlur,
                      offset: _glowOffset)
                ]
              : null,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: onPressed,
            child: PillButtonLabel(
              label: label,
              icon: icon,
              expand: expand,
              color: labelColor,
            ),
          ),
        ),
      ),
    );
  }
}
