import 'package:flutter/material.dart';

import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_tokens.dart';

class SortButton extends StatelessWidget {
  const SortButton({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    final style = Theme.of(context)
        .textTheme
        .titleSmall
        ?.copyWith(color: tokens.accentText);
    return Tooltip(
      message: 'Sort',
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.pill),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: style),
              const SizedBox(width: 4),
              Icon(Icons.expand_more_rounded,
                  size: AppSizes.icon, color: tokens.accentText),
            ],
          ),
        ),
      ),
    );
  }
}
