import 'package:flutter/material.dart';

import '../../../core/app/app_name.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_spacing.dart';

class LibraryHeader extends StatelessWidget {
  const LibraryHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen, 16, AppSpacing.screen, 0),
      // Keeps the height the rescan button used to give the header, so the
      // search field and tabs below don't move up.
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSizes.roundButton),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(appName.toUpperCase(), style: text.labelSmall),
            const SizedBox(height: 4),
            Text('Library', style: text.headlineLarge),
          ],
        ),
      ),
    );
  }
}
