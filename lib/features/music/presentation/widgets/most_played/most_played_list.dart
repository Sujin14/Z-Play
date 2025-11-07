import 'package:flutter/material.dart';
import 'package:musicplayer/features/music/presentation/widgets/most_played/most_played_tile.dart';
import '../../viewmodels/music_viewmodel.dart';
import '../../viewmodels/playlist_viewmodel.dart';

class MostPlayedList extends StatelessWidget {
  final MusicViewModel musicVM;
  final PlaylistViewModel playlistVM;

  const MostPlayedList({
    super.key,
    required this.musicVM,
    required this.playlistVM,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: musicVM.mostPlayedSongs.length,
      itemBuilder: (context, index) {
        final musicFile = musicVM.mostPlayedSongs[index];
        final isFavorite = musicVM.isFavorite(musicFile);

        return MostPlayedTile(
          musicFile: musicFile,
          index: index,
          musicVM: musicVM,
          playlistVM: playlistVM,
          isFavorite: isFavorite,
        );
      },
    );
  }
}
