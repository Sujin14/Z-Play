import 'package:flutter/material.dart';

import '../../../core/theme/app_sizes.dart';
import '../../../core/widgets/round_icon_button.dart';

class PlayerTopBar extends StatelessWidget {
  const PlayerTopBar({super.key, required this.fromLine});

  // "From <album>"; the line is left out when null.
  final String? fromLine;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          RoundIconButton(
            icon: Icons.keyboard_arrow_down_rounded,
            tooltip: 'Close',
            onPressed: () => Navigator.maybePop(context),
          ),
          Expanded(
            child: Column(
              children: [
                Text('NOW PLAYING', style: text.labelSmall),
                if (fromLine != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    fromLine!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
          // Same width as the close button keeps the title centered.
          const SizedBox(width: AppSizes.roundButton),
        ],
      ),
    );
  }
}
