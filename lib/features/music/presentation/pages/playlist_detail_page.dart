import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../constants/themes.dart';
import '../../../../core/navigation/navigation_service.dart';
import '../../../../core/navigation/router.dart';
import '../viewmodels/music_viewmodel.dart';
import '../viewmodels/playlist_viewmodel.dart';
import '../../domain/entities/playlist_entity.dart';
import '../widgets/playlist/dialogs/add_songs_to_playlist_dialog.dart';
import '../widgets/playlist/playlist_detail_appbar.dart';
import '../widgets/playlist/playlist_empty_view.dart';
import '../widgets/playlist/playlist_song_tile.dart';


class PlaylistDetailScreen extends StatelessWidget {
  final PlaylistEntity playlist;
  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    final hi = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final musicViewModel = Provider.of<MusicViewModel>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PlaylistDetailAppBar(
        playlistName: playlist.name,
        onAddPressed: () => showAddSongsToPlaylistDialog(context, playlist),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.colorScheme.gradientStart, theme.colorScheme.gradientEnd],
          ),
        ),
        child: SafeArea(
          child: Consumer<PlaylistViewModel>(
            builder: (context, playlistViewModel, _) {
              final currentPlaylist = playlistViewModel.playlists.firstWhere(
                (p) => p.name == playlist.name,
                orElse: () => playlist,
              );

              if (currentPlaylist.songs.isEmpty) {
                return PlaylistEmptyView(hi: hi);
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: currentPlaylist.songs.length,
                itemBuilder: (context, index) {
                  final song = currentPlaylist.songs[index];
                  final isFavorite = musicViewModel.isFavorite(song);

                  return PlaylistSongTile(
                    hi: hi,
                    song: song,
                    playlist: currentPlaylist,
                    isFavorite: isFavorite,
                    onDelete: () async {
                      await playlistViewModel.removeSongFromPlaylist(playlist, song);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${song.title} removed from ${playlist.name}'),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.all(10),
                        ),
                      );
                    },
                    onFavoriteToggle: () => musicViewModel.toggleFavoriteSong(song),
                    onPlay: () {
                      musicViewModel.playMusic(song, currentPlaylist.songs, index);
                      NavigationService.pushNamed(
                        AppRoutes.musicPlayer,
                        arguments: {'musicFile': song, 'playlist': currentPlaylist.songs},
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
