import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/state/player_view_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/cover_art.dart';
import '../../../core/widgets/marquee_text.dart';

// Renders nothing when no song is loaded.
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key, required this.player, required this.onOpen});

  final PlayerViewModel player;
  final VoidCallback onOpen;

  static const double _blur = 20;
  static const double _progressHeight = 3;

  @override
  Widget build(BuildContext context) {
    final song = player.current;
    if (song == null) return const SizedBox.shrink();
    final tokens = AppTokens.of(context);
    final text = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(AppRadii.miniPlayer);
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: _blur, sigmaY: _blur),
        child: Material(
          color: tokens.glass,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: BorderSide(color: tokens.line),
          ),
          child: InkWell(
            onTap: onOpen,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 4, 10),
                  child: Row(
                    children: [
                      CoverArt(
                          seed: song.title,
                          size: AppSizes.smallCover,
                          radius: AppRadii.small),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            MarqueeText(song.title, style: text.titleMedium!),
                            Text(
                              song.artist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: text.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      _PlayButton(
                          playing: player.isPlaying, onPressed: player.toggle),
                      IconButton(
                        tooltip: 'Close player',
                        onPressed: player.stop,
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  // Listens to position directly so only the line repaints on
                  // every tick, not the whole bar.
                  child: ValueListenableBuilder<Duration>(
                    valueListenable: player.position,
                    builder: (context, position, _) {
                      final total = player.duration.inMilliseconds;
                      final progress = total <= 0
                          ? 0.0
                          : (position.inMilliseconds / total).clamp(0.0, 1.0);
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: progress,
                          child: Container(
                            height: _progressHeight,
                            decoration:
                                const BoxDecoration(gradient: AppColors.action),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.playing, required this.onPressed});

  final bool playing;
  final VoidCallback onPressed;

  static const double _size = 48;
  static const double _iconSize = 28;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: playing ? 'Pause' : 'Play',
      child: Tooltip(
        message: playing ? 'Pause' : 'Play',
        child: Material(
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: Ink(
            width: _size,
            height: _size,
            decoration: const BoxDecoration(gradient: AppColors.action),
            child: InkWell(
              onTap: onPressed,
              child: Icon(
                playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: AppColors.onAccent,
                size: _iconSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
