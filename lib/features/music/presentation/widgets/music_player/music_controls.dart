import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/music_viewmodel.dart';
import '../../viewmodels/playlist_viewmodel.dart';
import '../playlist/dialogs/add_to_playlist_dialog.dart';
import '../../../../../constants/themes.dart';

class MusicControls extends StatelessWidget {
  final double hi;
  const MusicControls({super.key, required this.hi});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final musicViewModel = Provider.of<MusicViewModel>(context);
    final playlistViewModel =
        Provider.of<PlaylistViewModel>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: hi / 3.6,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              theme.colorScheme.gradientControlStart.withOpacity(0.12),
              theme.colorScheme.gradientControlEnd.withOpacity(0.10)
            ], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: const BorderRadius.all(Radius.circular(24)),
            border: Border.all(color: theme.colorScheme.glassBorder),
          ),
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPlaybackControls(context, musicViewModel),
              _buildAdditionalControls(
                  context, musicViewModel, playlistViewModel),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaybackControls(
      BuildContext context, MusicViewModel musicViewModel) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
            onPressed: musicViewModel.playPrevious,
            icon: Icon(Icons.skip_previous_rounded,
                size: 36, color: theme.textTheme.bodyLarge!.color)),
        SizedBox(
          height: 72,
          width: 72,
          child: FloatingActionButton(
            backgroundColor: theme.colorScheme.primary,
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
                size: 40),
          ),
        ),
        IconButton(
            onPressed: musicViewModel.playNext,
            icon: Icon(Icons.skip_next_rounded,
                size: 36, color: theme.textTheme.bodyLarge!.color)),
      ],
    );
  }

  Widget _buildAdditionalControls(BuildContext context,
      MusicViewModel musicViewModel, PlaylistViewModel playlistViewModel) {
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
                color: theme.textTheme.bodyLarge!.color)),
        IconButton(
            onPressed: musicViewModel.toggleShuffle,
            icon: Icon(
                musicViewModel.isShuffling
                    ? Icons.shuffle
                    : Icons.shuffle_outlined,
                color: musicViewModel.isShuffling
                    ? theme.colorScheme.shuffleIcon
                    : theme.colorScheme.favoriteIconEmpty)),
        IconButton(
            onPressed: () {
              if (musicViewModel.currentMusicFile != null)
                showPlaylistDialog(context, playlistViewModel,
                    musicViewModel.currentMusicFile!);
            },
            icon: const Icon(Icons.playlist_play)),
        IconButton(
            onPressed: () {
              if (musicViewModel.currentMusicFile != null)
                musicViewModel
                    .toggleFavoriteSong(musicViewModel.currentMusicFile!);
            },
            icon: Icon(
                musicViewModel.currentMusicFile != null &&
                        musicViewModel
                            .isFavorite(musicViewModel.currentMusicFile!)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: musicViewModel.currentMusicFile != null &&
                        musicViewModel
                            .isFavorite(musicViewModel.currentMusicFile!)
                    ? theme.colorScheme.favoriteIconFilled
                    : theme.colorScheme.favoriteIconEmpty)),
      ],
    );
  }
}
