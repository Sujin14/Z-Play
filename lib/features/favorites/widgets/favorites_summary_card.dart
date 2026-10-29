import 'package:flutter/material.dart';

import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/play_shuffle_buttons.dart';

class FavoritesSummaryCard extends StatelessWidget {
  const FavoritesSummaryCard({
    super.key,
    required this.count,
    required this.duration,
    required this.onPlayAll,
    required this.onShuffle,
  });

  final String count;
  // Left out when empty.
  final String duration;
  final VoidCallback onPlayAll;
  final VoidCallback onShuffle;

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
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: count, style: text.titleSmall),
                if (duration.isNotEmpty)
                  TextSpan(text: ' · $duration', style: text.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PlayShuffleButtons(onPlayAll: onPlayAll, onShuffle: onShuffle),
        ],
      ),
    );
  }
}
