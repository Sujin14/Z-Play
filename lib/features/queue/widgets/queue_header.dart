import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/ghost_button.dart';
import '../../../core/widgets/round_icon_button.dart';

class QueueHeader extends StatelessWidget {
  const QueueHeader({super.key, required this.subtitle, required this.onSave});

  // "N songs · duration"; hidden when the queue is empty.
  final String? subtitle;
  // Null disables "Save as playlist".
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    // Stretch keeps the full-width layout these rows had as separate slivers.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen, 12, AppSpacing.screen, 0),
          child: Row(
            children: [
              RoundIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                tooltip: 'Back',
                onPressed: () => Navigator.maybePop(context),
              ),
              const Spacer(),
              GhostButton(
                label: 'Save as playlist',
                icon: Icons.playlist_add_rounded,
                accent: true,
                onPressed: onSave,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen, 20, AppSpacing.screen, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Queue', style: text.headlineLarge),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!,
                    style: text.bodyLarge
                        ?.copyWith(color: AppTokens.of(context).text2)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
