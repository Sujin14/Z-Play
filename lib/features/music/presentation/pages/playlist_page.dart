import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/playlist_viewmodel.dart';
import '../viewmodels/music_viewmodel.dart';
import '../widgets/playlist_card.dart';
import '../widgets/playlist_dialogs.dart';
import '../../../../constants/themes.dart';

class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final playlistVM = Provider.of<PlaylistViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Playlists',
            style: style(
                fontSize: hi / 30, color: theme.textTheme.bodyLarge!.color)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 30),
            onPressed: () {
              final musicVM =
                  Provider.of<MusicViewModel>(context, listen: false);

              showCreateOrEditPlaylistDialog(
                context: context,
                playlistViewModel: playlistVM,
                musicViewModel: musicVM,
              );
            },
          ),
        ],
      ),
      body: playlistVM.isLoading
          ? Center(
              child: CircularProgressIndicator(
              color: theme.colorScheme.primary,
            ))
          : playlistVM.playlists.isEmpty
              ? Center(
                  child: Text('No playlists created yet!',
                      style: style(
                          fontSize: hi / 50, fontWeight: FontWeight.normal)),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: playlistVM.playlists.length,
                  itemBuilder: (_, index) =>
                      PlaylistCard(playlist: playlistVM.playlists[index]),
                ),
    );
  }
}
