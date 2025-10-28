import 'package:flutter/material.dart';
import 'package:musicplayer/constants/themes.dart';
import '../viewmodels/music_viewmodel.dart';

class MusicSlider extends StatelessWidget {
  final MusicViewModel musicViewModel;
  final double hi;
  final double wi;

  const MusicSlider({
    super.key,
    required this.musicViewModel,
    required this.hi,
    required this.wi,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(formatDuration(musicViewModel.currentPosition),
              style: TextStyle(fontSize: hi / 60)),
          SizedBox(
              width: wi / 1.5,
              child: Slider(
                inactiveColor: theme.colorScheme.favoriteIconEmpty,
                activeColor: theme.colorScheme.trendingIcon,
                thumbColor: theme.scaffoldBackgroundColor,
                value: musicViewModel.totalDuration.inSeconds > 0
                    ? musicViewModel.currentPosition.inSeconds
                        .clamp(0, musicViewModel.totalDuration.inSeconds)
                        .toDouble()
                    : 0,
                max: musicViewModel.totalDuration.inSeconds > 0
                    ? musicViewModel.totalDuration.inSeconds.toDouble()
                    : 1,
                onChanged: (value) {
                  if (musicViewModel.totalDuration.inSeconds > 0) {
                    musicViewModel.seekMusic(Duration(seconds: value.toInt()));
                  }
                },
              )),
          Text(formatDuration(musicViewModel.totalDuration),
              style: TextStyle(fontSize: hi / 60)),
        ],
      ),
    );
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
  }
}