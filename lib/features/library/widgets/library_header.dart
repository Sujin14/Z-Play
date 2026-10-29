import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/round_icon_button.dart';

class LibraryHeader extends StatelessWidget {
  const LibraryHeader({super.key, required this.onRescan});

  // Null while a scan is running, which disables the button.
  final VoidCallback? onRescan;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen, 16, AppSpacing.screen, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Z-PLAY', style: text.labelSmall),
                const SizedBox(height: 4),
                Text('Library', style: text.headlineLarge),
              ],
            ),
          ),
          RoundIconButton(
            tooltip: 'Rescan library',
            icon: Icons.refresh_rounded,
            onPressed: onRescan,
          ),
        ],
      ),
    );
  }
}
