import 'package:flutter/material.dart';
import 'package:musicplayer/constants/themes.dart';
import 'package:musicplayer/features/music/domain/entities/music_file_entity.dart';
import '../../../../../core/navigation/navigation_service.dart';
import '../../../../../core/navigation/router.dart';
import '../../viewmodels/music_viewmodel.dart';
import '../../viewmodels/playlist_viewmodel.dart';
import '../playlist/dialogs/add_to_playlist_dialog.dart';
import 'glass_list_tile.dart';

class MusicList extends StatelessWidget {
  final List<MusicFileEntity> filteredMusicFiles;
  final MusicViewModel musicVM;
  final PlaylistViewModel playlistVM;

  const MusicList({
    super.key,
    required this.filteredMusicFiles,
    required this.musicVM,
    required this.playlistVM,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hi = MediaQuery.of(context).size.height;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: filteredMusicFiles.length,
      itemBuilder: (context, index) {
        final musicFile = filteredMusicFiles[index];
        final isFavorite = musicVM.isFavorite(musicFile);

        return GlassListTile(
          title: musicFile.title,
          leadingIcon: Icons.music_note,
          accentColor: theme.colorScheme.primary,
          marqueeHeight: hi / 25,
          onTap: () {
            musicVM.playMusic(musicFile, filteredMusicFiles, index);
            NavigationService.pushNamed(
              AppRoutes.musicPlayer,
              arguments: {
                'musicFile': musicFile,
                'playlist': filteredMusicFiles,
              },
            );
          },
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon:
                    Icon(Icons.playlist_add, color: theme.colorScheme.tertiary),
                onPressed: () =>
                    showPlaylistDialog(context, playlistVM, musicFile),
              ),
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite
                      ? theme.colorScheme.favoriteIconFilled
                      : theme.colorScheme.favoriteIconEmpty,
                ),
                onPressed: () {
                  musicVM.toggleFavoriteSong(musicFile);
                  final updated = musicVM.isFavorite(musicFile);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: theme.colorScheme.favoriteIconFilled,
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.all(10),
                      content: Text(
                        updated
                            ? "Removed from Favorites"
                            : "Added to Favorites",
                        style: TextStyle(
                            fontSize: hi / 50,
                            color: theme.textTheme.bodyLarge!.color),
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
