import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:musicplayer/features/music/presentation/pages/music_player_page.dart';
import '../../viewmodels/music_viewmodel.dart';
import 'mini_player_container.dart';

class MiniPlayer extends StatelessWidget {
  final MusicViewModel musicViewModel;

  const MiniPlayer({super.key, required this.musicViewModel});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: const Key('mini_player'),
      direction: DismissDirection.down,
      onDismissed: (_) {
        musicViewModel.stopAndClearMusic();
      },
      child: GestureDetector(
        onTap: () {
          if (musicViewModel.currentMusicFile == null) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MusicPlayer(
                musicFile: musicViewModel.currentMusicFile!,
                playlist: musicViewModel.currentPlaylist,
              ),
            ),
          );
        },
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: const MiniPlayerContainer(),
          ),
        ),
      ),
    );
  }
}
