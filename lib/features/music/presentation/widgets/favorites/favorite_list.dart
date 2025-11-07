import 'package:flutter/material.dart';
import '../../viewmodels/music_viewmodel.dart';
import '../../viewmodels/playlist_viewmodel.dart';
import 'favorite_tile.dart';

class FavoriteList extends StatelessWidget {
  final List favorites;
  final MusicViewModel musicViewModel;
  final PlaylistViewModel playlistViewModel;

  const FavoriteList({
    super.key,
    required this.favorites,
    required this.musicViewModel,
    required this.playlistViewModel,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final musicFile = favorites[index];
        return FavoriteTile(
          musicFile: musicFile,
          index: index,
          musicViewModel: musicViewModel,
          playlistViewModel: playlistViewModel,
        );
      },
    );
  }
}
