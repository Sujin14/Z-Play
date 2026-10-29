import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/song_model.dart';
import '../services/song_actions.dart';
import '../state/library_view_model.dart';
import '../state/player_view_model.dart';
import '../theme/app_spacing.dart';
import '../theme/app_tokens.dart';
import 'equalizer_bars.dart';
import 'song_menu_sheet.dart';
import 'song_tile.dart';

class SongSliverList extends StatelessWidget {
  const SongSliverList({
    super.key,
    required this.songs,
    this.numbered = false,
    this.showFavoriteHeart = true,
    this.subtitleFor,
    this.onRemove,
  });

  final List<Song> songs;

  // Album style: a track number (or the equalizer) instead of the cover.
  final bool numbered;
  final bool showFavoriteHeart;
  final String Function(Song song)? subtitleFor;
  final void Function(Song song)? onRemove;

  static const double _numberWidth = 24;

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryViewModel>();
    final player = context.watch<PlayerViewModel>();
    final current = player.current;
    final tokens = AppTokens.of(context);
    final numberStyle =
        Theme.of(context).textTheme.bodyLarge?.copyWith(color: tokens.text2);
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.list),
      sliver: SliverList.builder(
        itemCount: songs.length,
        itemBuilder: (context, index) {
          final song = songs[index];
          final isCurrent = song == current;
          final playing = isCurrent && player.isPlaying;
          return SongTile(
            song: song,
            favorite: showFavoriteHeart && library.isFavorite(song),
            current: isCurrent,
            playing: playing,
            showCover: !numbered,
            subtitle: subtitleFor?.call(song),
            leading: numbered
                ? SizedBox(
                    width: _numberWidth,
                    child: Center(
                      child: isCurrent
                          // Not on a cover here, so it needs the text-strength green.
                          ? EqualizerBars(
                              animate: playing, color: tokens.accentText)
                          : Text('${index + 1}', style: numberStyle),
                    ),
                  )
                : null,
            onTap: () => playFromList(context, songs, index),
            onMore: () => showSongMenu(
              context,
              song,
              onRemove: onRemove == null ? null : () => onRemove!(song),
            ),
          );
        },
      ),
    );
  }
}
