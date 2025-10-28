import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';
import '../../../../core/navigation/router.dart';
import '../viewmodels/music_viewmodel.dart';
import '../viewmodels/playlist_viewmodel.dart';
import '../widgets/playlist_dialogs.dart';
import '../../../../core/navigation/navigation_service.dart';
import '../../../../constants/themes.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final musicViewModel = Provider.of<MusicViewModel>(context);
    final playlistViewModel = Provider.of<PlaylistViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Favorites',
          style: style(fontSize: hi / 30, color: theme.textTheme.bodyLarge!.color),
        ),
      ),
      body: musicViewModel.isLoading
          ? Center(child: CircularProgressIndicator(color: theme.colorScheme.primary,))
          : musicViewModel.favorites.isEmpty
              ? Center(
                  child: Text(
                    'No favorite songs added yet!',
                    style: style(fontSize: hi / 50, fontWeight: FontWeight.normal),
                  ),
                )
              : ListView.builder(
                  itemCount: musicViewModel.favorites.length,
                  itemBuilder: (context, index) {
                    final musicFile = musicViewModel.favorites[index];
                    return Card(
                      color: theme.colorScheme.cardBackground,
                      child: ListTile(
                        leading: Icon(Icons.music_note_outlined, color: theme.colorScheme.musicIcon),
                        title: SizedBox(
                          height: hi / 25,
                          width: double.infinity,
                          child: Marquee(
                            text: musicFile.title,
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
                          musicViewModel.playMusic(
                            musicFile,
                            musicViewModel.favorites,
                            index,
                          );
                          NavigationService.pushNamed(
                            AppRoutes.musicPlayer,
                            arguments: {
                              'musicFile': musicFile,
                              'playlist': musicViewModel.favorites,
                            },
                          );
                        },
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.playlist_add, color: theme.colorScheme.favoriteIconEmpty),
                              onPressed: () {
                                showPlaylistDialog(context, playlistViewModel, musicFile);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.favorite, color: theme.colorScheme.favoriteIconFilled),
                              onPressed: () {
                                musicViewModel.toggleFavoriteSong(musicFile);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}