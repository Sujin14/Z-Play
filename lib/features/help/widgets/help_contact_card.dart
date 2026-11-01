import 'package:flutter/material.dart';

import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/ghost_button.dart';

class HelpContactCard extends StatelessWidget {
  const HelpContactCard({
    super.key,
    required this.eyebrow,
    required this.message,
    required this.email,
    required this.copyLabel,
    required this.onCopy,
  });

  final String eyebrow;
  final String message;
  final String email;
  final String copyLabel;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: tokens.card,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: tokens.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(eyebrow,
              style: text.labelSmall?.copyWith(color: tokens.accentText)),
          const SizedBox(height: 8),
          Text(message, style: text.bodyLarge?.copyWith(color: tokens.text2)),
          const SizedBox(height: 12),
          SelectableText(email, style: text.titleMedium),
          const SizedBox(height: 16),
          GhostButton(
            label: copyLabel,
            icon: Icons.copy_rounded,
            accent: true,
            onPressed: onCopy,
          ),
        ],
      ),
    );
  }
}
