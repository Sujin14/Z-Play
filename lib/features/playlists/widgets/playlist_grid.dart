import 'package:flutter/material.dart';

import '../../../core/models/user_playlist_model.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/layout_utils.dart';
import 'playlist_card.dart';

class PlaylistGrid extends StatelessWidget {
  const PlaylistGrid({
    super.key,
    required this.playlists,
    required this.subtitleFor,
    required this.onOpen,
    required this.onRename,
    required this.onDelete,
  });

  final List<UserPlaylist> playlists;
  final String Function(UserPlaylist playlist) subtitleFor;
  final ValueChanged<UserPlaylist> onOpen;
  final ValueChanged<UserPlaylist> onRename;
  final ValueChanged<UserPlaylist> onDelete;

  static const _columns = 2;
  static const double _spacing = 16;
  static const double _rowSpacing = 20;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth =
            (constraints.maxWidth - AppSpacing.screen * 2 - _spacing) /
                _columns;
        return GridView.builder(
          padding: tabListPadding(context, AppSpacing.screen),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _columns,
            crossAxisSpacing: _spacing,
            mainAxisSpacing: _rowSpacing,
            mainAxisExtent: coverGridCellExtent(context, itemWidth),
          ),
          itemCount: playlists.length,
          itemBuilder: (context, index) {
            final playlist = playlists[index];
            return PlaylistCard(
              name: playlist.name,
              subtitle: subtitleFor(playlist),
              coverSeeds: playlist.coverSeeds,
              size: itemWidth,
              onOpen: () => onOpen(playlist),
              onRename: () => onRename(playlist),
              onDelete: () => onDelete(playlist),
            );
          },
        );
      },
    );
  }
}
