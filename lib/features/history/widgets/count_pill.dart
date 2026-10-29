import 'package:flutter/material.dart';

import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_tokens.dart';

class CountPill extends StatelessWidget {
  const CountPill(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: tokens.chip,
          borderRadius: BorderRadius.circular(AppRadii.pill)),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: tokens.accentText,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
