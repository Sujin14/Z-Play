import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/state/playlist_view_model.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/playlist_editor_sheet.dart';
import '../view_model/playlists_view_model.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/playlist_grid.dart';
import '../widgets/playlists_header.dart';

class PlaylistsView extends StatelessWidget {
  const PlaylistsView({super.key});

  @override
  Widget build(BuildContext context) {
    final grid = PlaylistsViewModel(context.watch<PlaylistViewModel>());
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PlaylistsHeader(onNew: () => showPlaylistEditor(context)),
            Expanded(
              child: grid.isEmpty
                  ? Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.paddingOf(context).bottom),
                      child: EmptyState(
                        icon: Icons.queue_music_rounded,
                        title: 'No playlists yet.',
                        message:
                            'Group songs your own way. Create your first playlist.',
                        actionLabel: 'Create playlist',
                        actionIcon: Icons.add_rounded,
                        onAction: () => showPlaylistEditor(context),
                      ),
                    )
                  : PlaylistGrid(
                      playlists: grid.playlists,
                      subtitleFor: grid.subtitleFor,
                      onOpen: grid.open,
                      onRename: (playlist) =>
                          showPlaylistEditor(context, playlist: playlist),
                      onDelete: (playlist) => grid.delete(
                        playlist.name,
                        confirm: () => showConfirmDialog(
                          context,
                          title: 'Delete playlist',
                          message: grid.deleteMessage(playlist.name),
                          confirmLabel: 'Delete',
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
