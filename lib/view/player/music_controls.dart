import 'package:flutter/material.dart';
import 'package:musicplayer/view/player/player_controls.dart';
import 'package:musicplayer/view_model/providers/music_provider.dart';
import 'package:musicplayer/view_model/providers/playlist_provider.dart';
import 'package:musicplayer/view_model/playlist/playlist_creation.dart';
import 'package:provider/provider.dart';

class MusicControls extends StatelessWidget {
  final MusicController musicController;
  final MusicProvider musicProvider;
  final double hi;

  const MusicControls(
      {super.key,
      required this.musicController,
      required this.musicProvider,
      required this.hi});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: hi / 3.3,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF23025D), Color(0xFF1891ED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.all(Radius.circular(50)),
      ),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildPlaybackControls(context),
          _buildAdditionalControls(context),
        ],
      ),
    );
  }

  Widget _buildPlaybackControls(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          onPressed: () => musicController.playPrevious(context),
          icon: const Icon(Icons.skip_previous_rounded, size: 40),
        ),
        SizedBox(
          height: 70,
          width: 70,
          child: FloatingActionButton(
            backgroundColor: Colors.green,
            onPressed: () {
              if (musicProvider.isPlaying) {
                musicProvider.pauseMusic();
              } else {
                musicProvider.resumeMusic();
              }
            },
            child: Icon(
              musicProvider.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
        IconButton(
          onPressed: () => musicController.playNext(context),
          icon: const Icon(Icons.skip_next_rounded, size: 40),
        ),
      ],
    );
  }

  Widget _buildAdditionalControls(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          onPressed: () => musicController.toggleRepeatMode(context),
          icon: Icon(musicController.repeatMode == RepeatMode.off
              ? Icons.repeat
              : (musicController.repeatMode == RepeatMode.one
                  ? Icons.repeat_one
                  : Icons.repeat)),
        ),
        IconButton(
          onPressed: () => musicController.toggleShuffle(musicProvider),
          icon: Icon(
            musicController.isShuffling
                ? Icons.shuffle
                : Icons.shuffle_outlined,
            color: musicController.isShuffling
                ? Colors.deepOrangeAccent
                : Colors.white,
          ),
        ),
        IconButton(
          onPressed: () {
            showPlaylistDialog(
                context,
                Provider.of<PlaylistProvider>(context, listen: false),
                musicProvider.currentMusicFile!);
          },
          icon: const Icon(Icons.playlist_play),
        ),
        IconButton(
          onPressed: () {
            musicProvider.toggleFavorite(musicProvider.currentMusicFile!);
          },
          icon: Icon(
            musicProvider.isFavorite(musicProvider.currentMusicFile!)
                ? Icons.favorite
                : Icons.favorite_border,
            color: musicProvider.isFavorite(musicProvider.currentMusicFile!)
                ? Colors.red
                : Colors.white,
          ),
        ),
      ],
    );
  }
}
