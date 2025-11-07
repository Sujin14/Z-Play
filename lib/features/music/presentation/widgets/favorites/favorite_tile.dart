import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:musicplayer/constants/themes.dart';

import '../../../../../core/navigation/navigation_service.dart';
import '../../../../../core/navigation/router.dart';
import '../../viewmodels/music_viewmodel.dart';
import '../../viewmodels/playlist_viewmodel.dart';
import '../playlist/dialogs/add_to_playlist_dialog.dart';

class FavoriteTile extends StatelessWidget {
  final dynamic musicFile;
  final int index;
  final MusicViewModel musicViewModel;
  final PlaylistViewModel playlistViewModel;

  const FavoriteTile({
    super.key,
    required this.musicFile,
    required this.index,
    required this.musicViewModel,
    required this.playlistViewModel,
  });

  @override
  Widget build(BuildContext context) {
    final hi = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.glassFill,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: theme.colorScheme.glassBorder),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                height: hi / 14,
                width: hi / 14,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.18),
                      theme.colorScheme.tertiary.withOpacity(0.12)
                    ],
                  ),
                ),
                child: Icon(Icons.music_note_outlined, color: theme.colorScheme.musicIcon),
              ),
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
                musicViewModel.playMusic(musicFile, musicViewModel.favorites, index);
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
                    icon: Icon(Icons.playlist_add, color: theme.colorScheme.tertiary),
                    onPressed: () => showPlaylistDialog(context, playlistViewModel, musicFile),
                  ),
                  IconButton(
                    icon: Icon(Icons.favorite, color: theme.colorScheme.favoriteIconFilled),
                    onPressed: () => musicViewModel.toggleFavoriteSong(musicFile),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
