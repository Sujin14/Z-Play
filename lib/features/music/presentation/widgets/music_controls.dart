import 'package:flutter/material.dart';
import 'package:musicplayer/constants/themes.dart';
import 'package:provider/provider.dart';
import '../viewmodels/music_viewmodel.dart';
import '../viewmodels/playlist_viewmodel.dart';
import 'playlist_dialogs.dart';

class MusicControls extends StatelessWidget {
  final double hi;
  const MusicControls({super.key, required this.hi});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final musicViewModel = Provider.of<MusicViewModel>(context);
    final playlistViewModel = Provider.of<PlaylistViewModel>(context, listen: false);

    return Container(
      height: hi / 3.3,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.gradientControlStart, theme.colorScheme.gradientControlEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(50)),
      ),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildPlaybackControls(context, musicViewModel),
          _buildAdditionalControls(context, musicViewModel, playlistViewModel),
        ],
      ),
    );
  }

  Widget _buildPlaybackControls(BuildContext context, MusicViewModel musicViewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          onPressed: musicViewModel.playPrevious,
          icon: const Icon(Icons.skip_previous_rounded, size: 40),
        ),
        SizedBox(
          height: 70,
          width: 70,
          child: FloatingActionButton(
            backgroundColor: Theme.of(context).colorScheme.trendingIcon,
            onPressed: () {
              if (musicViewModel.isPlaying) {
                musicViewModel.pauseMusic();
              } else {
                musicViewModel.resumeMusic();
              }
            },
            child: Icon(
              musicViewModel.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Theme.of(context).textTheme.bodyLarge!.color,
              size: 40,
            ),
          ),
        ),
        IconButton(
          onPressed: musicViewModel.playNext,
          icon: const Icon(Icons.skip_next_rounded, size: 40),
        ),
      ],
    );
  }

  Widget _buildAdditionalControls(
      BuildContext context, MusicViewModel musicViewModel, PlaylistViewModel playlistViewModel) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          onPressed: musicViewModel.toggleRepeatMode,
          icon: Icon(
            musicViewModel.repeatMode == RepeatMode.off
                ? Icons.repeat
                : (musicViewModel.repeatMode == RepeatMode.one
                    ? Icons.repeat_one
                    : Icons.repeat),
          ),
        ),
        IconButton(
          onPressed: musicViewModel.toggleShuffle,
          icon: Icon(
            musicViewModel.isShuffling ? Icons.shuffle : Icons.shuffle_outlined,
            color: musicViewModel.isShuffling ? theme.colorScheme.shuffleIcon : theme.colorScheme.favoriteIconEmpty,
          ),
        ),
        IconButton(
          onPressed: () {
            if (musicViewModel.currentMusicFile != null) {
              showPlaylistDialog(context, playlistViewModel, musicViewModel.currentMusicFile!);
            }
          },
          icon: const Icon(Icons.playlist_play),
        ),
        IconButton(
          onPressed: () {
            if (musicViewModel.currentMusicFile != null) {
              musicViewModel.toggleFavoriteSong(musicViewModel.currentMusicFile!);
            }
          },
          icon: Icon(
            musicViewModel.currentMusicFile != null &&
                    musicViewModel.isFavorite(musicViewModel.currentMusicFile!)
                ? Icons.favorite
                : Icons.favorite_border,
            color: musicViewModel.currentMusicFile != null &&
                    musicViewModel.isFavorite(musicViewModel.currentMusicFile!)
                ? theme.colorScheme.favoriteIconFilled
                : theme.colorScheme.favoriteIconEmpty,
          ),
        ),
      ],
    );
  }
}