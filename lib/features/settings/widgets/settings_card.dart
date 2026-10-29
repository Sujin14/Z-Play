import 'package:flutter/material.dart';

import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_tokens.dart';

class SettingsCard extends StatelessWidget {
  const SettingsCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    final radius = BorderRadius.circular(AppRadii.miniPlayer);
    return Material(
      color: tokens.card,
      shape: RoundedRectangleBorder(
          borderRadius: radius, side: BorderSide(color: tokens.line)),
      // Clips the row ripples to the rounded corners.
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) Divider(height: 1, color: tokens.line),
            children[i],
          ],
        ],
      ),
    );
  }
}
