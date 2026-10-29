import 'package:flutter/material.dart';

import '../theme/app_sizes.dart';

// Shared inside of PrimaryButton and GhostButton, so both keep the same
// height, padding and icon spacing.
class PillButtonLabel extends StatelessWidget {
  const PillButtonLabel({
    super.key,
    required this.label,
    required this.icon,
    required this.expand,
    required this.color,
  });

  final String label;
  final IconData? icon;
  final bool expand;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
          minHeight: AppSizes.buttonHeight, minWidth: AppSizes.touchTarget),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: AppSizes.icon, color: color),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
