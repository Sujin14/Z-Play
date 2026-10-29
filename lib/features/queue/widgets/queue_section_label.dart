import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_tokens.dart';

// A sliver, so it can sit directly between the queue's reorderable lists.
class QueueSectionLabel extends StatelessWidget {
  const QueueSectionLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.screen, 24, AppSpacing.screen, 10),
        child: Text(
          label.toUpperCase(),
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(color: AppTokens.of(context).text2),
        ),
      ),
    );
  }
}
