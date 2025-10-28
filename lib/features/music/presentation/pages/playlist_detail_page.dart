import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';
import '../../../../core/navigation/router.dart';
import '../viewmodels/music_viewmodel.dart';
import '../viewmodels/playlist_viewmodel.dart';
import '../widgets/playlist_dialogs.dart';
import '../../domain/entities/playlist_entity.dart';
import '../../../../core/navigation/navigation_service.dart';
import '../../../../constants/themes.dart';

class PlaylistDetailScreen extends StatelessWidget {
  final PlaylistEntity playlist;

  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    final hi = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final musicViewModel = Provider.of<MusicViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          playlist.name,
          style: style(fontSize: hi / 30, color: theme.textTheme.bodyLarge!.color),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 30),
            onPressed: () {
              showAddSongsToPlaylistDialog(context, playlist);
            },
          ),
        ],
      ),
      body: Consumer<PlaylistViewModel>(
        builder: (context, playlistViewModel, child) {
          final currentPlaylist = playlistViewModel.playlists.firstWhere(
            (p) => p.name == playlist.name,
            orElse: () => playlist,
          );

          return currentPlaylist.songs.isEmpty
              ? Center(
                  child: Text(
                    'No songs in this playlist!',
                    style: style(fontSize: hi / 50, fontWeight: FontWeight.normal),
                  ),
                )
              : ListView.builder(
                  itemCount: currentPlaylist.songs.length,
                  itemBuilder: (context, index) {
                    final song = currentPlaylist.songs[index];
                    final isFavorite = musicViewModel.isFavorite(song);
                    return Card(
                      color: theme.colorScheme.cardBackground,
                      child: ListTile(
                        leading: Icon(Icons.music_note, color: theme.colorScheme.musicIcon),
                        title: SizedBox(
                          height: hi / 25,
                          width: double.infinity,
                          child: Marquee(
                            text: song.title,
                            style: style(fontSize: hi / 50, fontWeight: FontWeight.bold),
                            scrollAxis: Axis.horizontal,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            blankSpace: 10,
                            velocity: 30.0,
                            startPadding: 10.0,
                            accelerationDuration: const Duration(seconds: 5),
                          ),
                        ),
                        onTap: () {
                          musicViewModel.playMusic(song, currentPlaylist.songs, index);
                          NavigationService.pushNamed(
                            AppRoutes.musicPlayer,
                            arguments: {
                              'musicFile': song,
                              'playlist': currentPlaylist.songs,
                            },
                          );
                        },
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.delete, color: theme.colorScheme.favoriteIconFilled),
                              onPressed: () async {
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
                            ),
                            IconButton(
                              icon: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite ? theme.colorScheme.favoriteIconFilled : theme.colorScheme.favoriteIconEmpty,
                              ),
                              onPressed: () {
                                musicViewModel.toggleFavoriteSong(song);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
        },
      ),
    );
  }
}