import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';
import '../../../../core/navigation/router.dart';
import '../viewmodels/music_viewmodel.dart';
import '../viewmodels/playlist_viewmodel.dart';
import '../widgets/playlist/dialogs/add_to_playlist_dialog.dart';
import '../../../../core/navigation/navigation_service.dart';
import '../../../../constants/themes.dart';

class RecentlyPlayedPage extends StatelessWidget {
  const RecentlyPlayedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final playlistViewModel =
        Provider.of<PlaylistViewModel>(context, listen: false);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text('Recently Played',
              style: style(
                  fontSize: hi / 30, color: theme.textTheme.bodyLarge!.color))),
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
          theme.colorScheme.gradientStart,
          theme.colorScheme.gradientEnd
        ])),
        child: SafeArea(
          child: Consumer<MusicViewModel>(
            builder: (context, musicViewModel, child) {
              if (musicViewModel.isLoading) {
                return Center(
                    child: CircularProgressIndicator(
                        color: theme.colorScheme.primary));
              }
              if (musicViewModel.recentlyPlayed.isEmpty) {
                return Center(
                    child: Text('No recently played songs!',
                        style: style(
                            fontSize: hi / 50, fontWeight: FontWeight.normal)));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: musicViewModel.recentlyPlayed.length,
                itemBuilder: (context, index) {
                  final musicFile = musicViewModel.recentlyPlayed[index];
                  final isFavorite = musicViewModel.isFavorite(musicFile);
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.glassFill,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: theme.colorScheme.glassBorder),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              height: hi / 14,
                              width: hi / 14,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: LinearGradient(colors: [
                                  theme.colorScheme.primary.withOpacity(0.12),
                                  theme.colorScheme.tertiary.withOpacity(0.12)
                                ]),
                              ),
                              child: Icon(Icons.history,
                                  color: theme.colorScheme.historyIcon),
                            ),
                            title: SizedBox(
                              height: hi / 25,
                              width: double.infinity,
                              child: Marquee(
                                text: musicFile.title,
                                style: style(
                                    fontSize: hi / 50,
                                    fontWeight: FontWeight.bold),
                                scrollAxis: Axis.horizontal,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                blankSpace: 10,
                                velocity: 30.0,
                                startPadding: 10.0,
                              ),
                            ),
                            onTap: () {
                              musicViewModel.playMusic(musicFile,
                                  musicViewModel.recentlyPlayed, index);
                              NavigationService.pushNamed(
                                AppRoutes.musicPlayer,
                                arguments: {
                                  'musicFile': musicFile,
                                  'playlist': musicViewModel.recentlyPlayed,
                                },
                              );
                            },
                            trailing:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              IconButton(
                                  icon: Icon(Icons.playlist_add,
                                      color: theme.colorScheme.tertiary),
                                  onPressed: () => showPlaylistDialog(
                                      context, playlistViewModel, musicFile)),
                              IconButton(
                                  icon: Icon(
                                      isFavorite
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: isFavorite
                                          ? theme.colorScheme.favoriteIconFilled
                                          : theme
                                              .colorScheme.favoriteIconEmpty),
                                  onPressed: () => musicViewModel
                                      .toggleFavoriteSong(musicFile)),
                            ]),
                          ),
                        ),
                      ),
                    ),
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
