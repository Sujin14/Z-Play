import 'package:flutter/material.dart';

import '../../../core/app/app_name.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/primary_button.dart';

class PlaylistsHeader extends StatelessWidget {
  const PlaylistsHeader({super.key, required this.onNew});

  final VoidCallback onNew;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen, 16, AppSpacing.screen, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appName.toUpperCase(), style: text.labelSmall),
                const SizedBox(height: 4),
                Text('Playlists', style: text.headlineLarge),
              ],
            ),
          ),
          PrimaryButton(
            label: 'New',
            icon: Icons.add_rounded,
            onPressed: onNew,
          ),
        ],
      ),
    );
  }
}
