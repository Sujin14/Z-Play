import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/ghost_button.dart';
import '../../../core/widgets/primary_button.dart';

const double _darkScrimAlpha = 0.55;
const double _lightScrimAlpha = 0.3;

// Resolves to true only when confirmed; dismissing counts as cancel.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
}) async {
  final dark = Theme.of(context).brightness == Brightness.dark;
  final confirmed = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black
        .withValues(alpha: dark ? _darkScrimAlpha : _lightScrimAlpha),
    builder: (context) => ConfirmDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
    ),
  );
  return confirmed ?? false;
}

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
  });

  final String title;
  final String message;
  final String confirmLabel;

  static const double _iconCircle = 56;
  static const double _iconTintAlpha = 0.16;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    final text = Theme.of(context).textTheme;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: _iconCircle,
              height: _iconCircle,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: tokens.heart.withValues(alpha: _iconTintAlpha),
              ),
              child: Icon(Icons.delete_outline_rounded, color: tokens.heart),
            ),
            const SizedBox(height: 16),
            Text(title, textAlign: TextAlign.center, style: text.titleLarge),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: text.bodyLarge?.copyWith(color: tokens.text2),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GhostButton(
                    label: 'Cancel',
                    expand: true,
                    onPressed: () => Navigator.pop(context, false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    label: confirmLabel,
                    expand: true,
                    destructive: true,
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
