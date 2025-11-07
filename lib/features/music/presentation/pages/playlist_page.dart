import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/playlist_viewmodel.dart';
import '../viewmodels/music_viewmodel.dart';
import '../widgets/favorites/loading_indicator.dart';
import '../widgets/playlist/dialogs/create_edit_playlist_dialog.dart';
import '../widgets/playlist/playlist_appbar.dart';
import '../widgets/playlist/playlist_empty_view.dart';
import '../widgets/playlist/playlist_grid.dart';
import '../../../../constants/themes.dart';

class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final playlistVM = Provider.of<PlaylistViewModel>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PlaylistAppBar(hi: hi),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.gradientStart,
              theme.colorScheme.gradientEnd,
            ],
          ),
        ),
        child: SafeArea(
          child: Builder(
            builder: (_) {
              if (playlistVM.isLoading) {
                return LoadingIndicator();
              } else if (playlistVM.playlists.isEmpty) {
                return PlaylistEmptyView(hi: hi);
              } else {
                return PlaylistGrid(playlists: playlistVM.playlists);
              }
            },
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
          onPressed: () {
            final musicVM = Provider.of<MusicViewModel>(context, listen: false);
            showCreateOrEditPlaylistDialog(
              context: context,
              playlistViewModel: playlistVM,
              musicViewModel: musicVM,
            );
          },
          backgroundColor: theme.colorScheme.primary,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
