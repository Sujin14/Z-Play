import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/song_actions.dart';
import '../../../core/state/playlist_view_model.dart';
import '../../../core/widgets/detail_top_bar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/gradient_scaffold.dart';
import '../../../core/widgets/playlist_editor_sheet.dart';
import '../../../core/widgets/round_icon_button.dart';
import '../../../core/widgets/song_sliver_list.dart';
import '../view_model/playlist_detail_view_model.dart';
import '../widgets/playlist_detail_header.dart';

class PlaylistDetailView extends StatefulWidget {
  const PlaylistDetailView({super.key, required this.name});

  // Only used to find the playlist the first time. After that the page follows
  // its id, so a rename keeps the page alive.
  final String name;

  @override
  State<PlaylistDetailView> createState() => _PlaylistDetailViewState();
}

class _PlaylistDetailViewState extends State<PlaylistDetailView> {
  Object? _id;

  @override
  Widget build(BuildContext context) {
    final detail = PlaylistDetailViewModel(
      context.watch<PlaylistViewModel>(),
      knownId: _id,
      openedName: widget.name,
    );
    final found = detail.playlist;
    _id ??= found?.id;
    return GradientScaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: DetailTopBar(
                eyebrow: 'Playlist',
                trailing: found == null
                    ? null
                    : RoundIconButton(
                        icon: Icons.edit_outlined,
                        tooltip: 'Edit playlist',
                        onPressed: () =>
                            showPlaylistEditor(context, playlist: found),
                      ),
              ),
            ),
            if (found == null)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  scrollable: false,
                  icon: Icons.playlist_remove_rounded,
                  title: 'This playlist is no longer available.',
                ),
              )
            else ...[
              SliverToBoxAdapter(
                child: PlaylistDetailHeader(
                  title: detail.title,
                  subtitle: detail.subtitle,
                  coverSeeds: detail.coverSeeds,
                  onPlayAll: detail.hasSongs
                      ? () => playAll(context, detail.songs)
                      : null,
                  onShuffle: detail.hasSongs
                      ? () => shuffleAll(context, detail.songs)
                      : null,
                ),
              ),
              if (!detail.hasSongs)
                SliverToBoxAdapter(
                  child: EmptyState(
                    scrollable: false,
                    icon: Icons.queue_music_rounded,
                    title: 'This playlist is empty.',
                    message: 'Add songs with Edit, or from any song\'s ⋮ menu.',
                    actionLabel: 'Add songs',
                    actionIcon: Icons.add_rounded,
                    onAction: () =>
                        showPlaylistEditor(context, playlist: found),
                  ),
                )
              else
                SongSliverList(
                  songs: detail.songs,
                  onRemove: detail.removeSong,
                ),
            ],
            SliverToBoxAdapter(
              child:
                  SizedBox(height: 24 + MediaQuery.paddingOf(context).bottom),
            ),
          ],
        ),
      ),
    );
  }
}
