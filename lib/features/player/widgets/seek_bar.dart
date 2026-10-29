import 'package:flutter/material.dart';

import '../../../core/state/player_view_model.dart';
import '../../../core/utils/format_utils.dart';

class SeekBar extends StatelessWidget {
  const SeekBar({super.key, required this.player});

  final PlayerViewModel player;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall;
    // Listens to position directly so only the bar repaints on every tick.
    return ValueListenableBuilder<Duration>(
      valueListenable: player.position,
      builder: (context, position, _) {
        // A max of 1 keeps the slider valid before the duration is known.
        final total = player.duration.inMilliseconds <= 0
            ? 1
            : player.duration.inMilliseconds;
        final value = position.inMilliseconds.clamp(0, total).toDouble();
        return Column(
          children: [
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              child: Slider(
                value: value,
                max: total.toDouble(),
                onChanged: (next) =>
                    player.seek(Duration(milliseconds: next.round())),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(formatClock(position), style: style),
                Text(formatClock(player.duration), style: style),
              ],
            ),
          ],
        );
      },
    );
  }
}
