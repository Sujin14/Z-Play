import 'package:flutter/material.dart';

import '../theme/app_radii.dart';
import '../theme/app_sizes.dart';
import '../theme/app_tokens.dart';

// Replaces whatever snackbar is showing instead of queueing behind it.
void showSnackPill(
  BuildContext context,
  String message, {
  IconData icon = Icons.check_rounded,
  bool error = false,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      content: SnackPill(message: message, icon: icon, error: error),
    ),
  );
}

class SnackPill extends StatelessWidget {
  const SnackPill({
    super.key,
    required this.message,
    this.icon = Icons.check_rounded,
    this.error = false,
  });

  final String message;
  final IconData icon;
  final bool error;

  static const double _iconCircle = 32;
  static const double _backgroundAlpha = 0.94;
  static const double _tintAlpha = 0.18;
  static const _shadow =
      BoxShadow(color: Color(0x40000000), blurRadius: 20, offset: Offset(0, 8));

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    final tint = error ? tokens.heart : tokens.accentText;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 16, 10),
      decoration: BoxDecoration(
        color: tokens.sheet.withValues(alpha: _backgroundAlpha),
        borderRadius: BorderRadius.circular(AppRadii.miniPlayer),
        border: Border.all(color: tokens.line),
        boxShadow: const [_shadow],
      ),
      child: Row(
        children: [
          Container(
            width: _iconCircle,
            height: _iconCircle,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tint.withValues(alpha: _tintAlpha),
            ),
            child: Icon(icon, size: AppSizes.iconSmall, color: tint),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        ],
      ),
    );
  }
}
