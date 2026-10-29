import 'package:flutter/material.dart';

import 'ghost_button.dart';
import 'primary_button.dart';

class PlayShuffleButtons extends StatelessWidget {
  const PlayShuffleButtons(
      {super.key, required this.onPlayAll, required this.onShuffle});

  final VoidCallback? onPlayAll;
  final VoidCallback? onShuffle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: PrimaryButton(
            label: 'Play all',
            icon: Icons.play_arrow_rounded,
            expand: true,
            onPressed: onPlayAll,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GhostButton(
            label: 'Shuffle',
            icon: Icons.shuffle_rounded,
            expand: true,
            onPressed: onShuffle,
          ),
        ),
      ],
    );
  }
}
