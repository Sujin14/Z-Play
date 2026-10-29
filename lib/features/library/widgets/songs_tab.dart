import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/song_actions.dart';
import '../../../core/state/player_view_model.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/layout_utils.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/song_menu_sheet.dart';
import '../../../core/widgets/song_tile.dart';
import '../view_model/library_tabs_view_model.dart';
import 'tab_empty_state.dart';

class SongsTab extends StatelessWidget {
  const SongsTab({super.key, required this.tabs});

  final LibraryTabsViewModel tabs;

  @override
  Widget build(BuildContext context) {
    if (tabs.showsError) {
      return TabEmptyState(
        EmptyState(
          error: true,
          icon: Icons.warning_amber_rounded,
          title: tabs.error,
          message:
              'Check that Z-PLAY can access your audio files, then try again.',
          actionLabel: 'Try again',
          actionIcon: Icons.refresh_rounded,
          onAction: tabs.library.rescan,
        ),
      );
    }
    final songs = tabs.songs;
    if (songs.isEmpty) {
      final searching = tabs.isSearching;
      return TabEmptyState(
        EmptyState(
          icon: searching ? Icons.search_off_rounded : Icons.music_off_outlined,
          title: searching
              ? 'No songs match your search.'
              : 'No songs found on this device.',
        ),
      );
    }
    // Watched here rather than in the screen so only this list rebuilds on
    // playback changes.
    final player = context.watch<PlayerViewModel>();
    final current = player.current;
    return ListView.builder(
      padding: tabListPadding(context, AppSpacing.list),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        final isCurrent = song == current;
        return SongTile(
          song: song,
          favorite: tabs.isFavorite(song),
          current: isCurrent,
          playing: isCurrent && player.isPlaying,
          onTap: () => playFromList(context, songs, index),
          onMore: () => showSongMenu(context, song),
        );
      },
    );
  }
}
