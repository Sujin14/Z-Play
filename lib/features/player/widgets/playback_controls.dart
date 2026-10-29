import 'package:flutter/material.dart' hide RepeatMode;

import '../../../core/models/repeat_mode_model.dart';
import '../../../core/state/player_view_model.dart';
import 'big_play_button.dart';
import 'toggle_icon_button.dart';

class PlaybackControls extends StatelessWidget {
  const PlaybackControls({
    super.key,
    required this.player,
    required this.shuffleTooltip,
    required this.repeatTooltip,
    required this.repeatActive,
  });

  final PlayerViewModel player;
  final String shuffleTooltip;
  final String repeatTooltip;
  final bool repeatActive;

  static const double _skipIconSize = 40;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ToggleIconButton(
          icon: Icons.shuffle_rounded,
          active: player.shuffling,
          tooltip: shuffleTooltip,
          onPressed: player.toggleShuffle,
        ),
        IconButton(
          tooltip: 'Previous',
          iconSize: _skipIconSize,
          onPressed: player.previous,
          icon: const Icon(Icons.skip_previous_rounded),
        ),
        BigPlayButton(playing: player.isPlaying, onPressed: player.toggle),
        IconButton(
          tooltip: 'Next',
          iconSize: _skipIconSize,
          onPressed: player.next,
          icon: const Icon(Icons.skip_next_rounded),
        ),
        ToggleIconButton(
          icon: player.repeatMode == RepeatMode.one
              ? Icons.repeat_one_rounded
              : Icons.repeat_rounded,
          active: repeatActive,
          tooltip: repeatTooltip,
          onPressed: player.cycleRepeat,
        ),
      ],
    );
  }
}
