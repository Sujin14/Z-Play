import 'package:flutter/material.dart';

import '../models/song_model.dart';
import '../theme/app_sizes.dart';
import '../theme/app_tokens.dart';
import '../utils/format_utils.dart';
import 'cover_art.dart';
import 'equalizer_bars.dart';

class SongTile extends StatelessWidget {
  const SongTile({
    super.key,
    required this.song,
    this.onTap,
    this.onMore,
    this.favorite = false,
    this.current = false,
    this.playing = false,
    this.leading,
    this.subtitle,
    this.trailing,
    this.showCover = true,
  });

  final Song song;
  final VoidCallback? onTap;

  // The ⋮ button is hidden when null.
  final VoidCallback? onMore;
  final bool favorite;

  // The loaded song, whether playing or paused.
  final bool current;

  // Only animates the equalizer; current decides the highlight.
  final bool playing;

  // Drawn before the cover, e.g. a track or rank number.
  final Widget? leading;

  final String? subtitle;

  // Replaces the duration, e.g. a "42×" pill.
  final Widget? trailing;

  // False for album track lists, which show a number in leading instead.
  final bool showCover;

  static const double _radius = 18;
  static const double _overlayAlpha = 0.45;
  static const double _heartSize = 14;
  // text2 drops to ~4.1:1 on the dark chip tint; this keeps 4.5:1.
  static const double _currentSubtitleAlpha = 0.82;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    final text = Theme.of(context).textTheme;
    return Material(
      color: current ? tokens.chip : Colors.transparent,
      borderRadius: BorderRadius.circular(_radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(_radius),
        onTap: onTap,
        child: Padding(
          // The ⋮ button brings its own padding on the right.
          padding: EdgeInsets.fromLTRB(10, 9, onMore == null ? 10 : 0, 9),
          child: Row(
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 12)],
              if (showCover) ...[
                CoverArt(
                  seed: song.title,
                  size: AppSizes.songCover,
                  child: current
                      ? DecoratedBox(
                          decoration: BoxDecoration(
                            color:
                                Colors.black.withValues(alpha: _overlayAlpha),
                          ),
                          child: SizedBox.expand(
                            child:
                                Center(child: EqualizerBars(animate: playing)),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 14),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            song.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.titleMedium?.copyWith(
                              color: current ? tokens.accentText : tokens.text,
                            ),
                          ),
                        ),
                        if (favorite) ...[
                          const SizedBox(width: 6),
                          Icon(Icons.favorite,
                              size: _heartSize, color: tokens.heart),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle ?? song.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: current
                          ? text.bodyMedium?.copyWith(
                              color: tokens.text
                                  .withValues(alpha: _currentSubtitleAlpha))
                          : text.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              trailing ??
                  (song.durationMs > 0
                      ? Text(formatClock(song.duration), style: text.bodyMedium)
                      : const SizedBox.shrink()),
              if (onMore != null)
                IconButton(
                  tooltip: 'Song actions',
                  onPressed: onMore,
                  icon: const Icon(Icons.more_vert),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
