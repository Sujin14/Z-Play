import 'package:flutter/material.dart';

import '../../../core/models/song_model.dart';
import '../../../core/state/player_view_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/widgets/cover_art.dart';
import '../../../core/widgets/equalizer_bars.dart';

class NowPlayingCard extends StatelessWidget {
  const NowPlayingCard({
    super.key,
    required this.song,
    required this.player,
    required this.onTap,
    required this.onRemove,
  });

  final Song song;
  final PlayerViewModel player;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  static const double _borderAlpha = 0.6;
  static const double _neonTintAlpha = 0.2;
  static const double _aquaTintAlpha = 0.08;
  static const double _overlayAlpha = 0.45;
  // text2 falls to ~3.6:1 on this tint in dark; this keeps 4.5:1.
  static const double _onTintAlpha = 0.82;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    final text = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(AppRadii.miniPlayer);
    final onTint = text.bodyMedium
        ?.copyWith(color: tokens.text.withValues(alpha: _onTintAlpha));
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(
            color: tokens.accentText.withValues(alpha: _borderAlpha)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.neon.withValues(alpha: _neonTintAlpha),
            AppColors.aqua.withValues(alpha: _aquaTintAlpha),
          ],
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
            child: Row(
              children: [
                CoverArt(
                  seed: song.title,
                  size: AppSizes.songCover,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: _overlayAlpha)),
                    child: SizedBox.expand(
                      child: Center(
                          child: EqualizerBars(animate: player.isPlaying)),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleMedium
                            ?.copyWith(color: tokens.accentText),
                      ),
                      const SizedBox(height: 2),
                      Text(song.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: onTint),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Listens to position directly so only the time repaints on
                // every tick.
                ValueListenableBuilder<Duration>(
                  valueListenable: player.position,
                  builder: (context, position, _) => Text(
                    '${formatClock(position)} / ${formatClock(player.duration)}',
                    style: onTint,
                  ),
                ),
                IconButton(
                  tooltip: 'Remove from queue',
                  onPressed: onRemove,
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
