import 'package:flutter/material.dart';
import '../../../../../constants/themes.dart';
import '../../viewmodels/music_viewmodel.dart';

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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.glassFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.glassBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(formatDuration(musicViewModel.currentPosition),
              style: TextStyle(
                  fontSize: hi / 62, color: theme.textTheme.bodyMedium!.color)),
          const SizedBox(width: 8),
          SizedBox(
            width: wi / 1.6,
            child: Slider(
              inactiveColor: theme.colorScheme.favoriteIconEmpty,
              activeColor: theme.colorScheme.trendingIcon,
              thumbColor: theme.colorScheme.primary,
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
            ),
          ),
          const SizedBox(width: 8),
          Text(formatDuration(musicViewModel.totalDuration),
              style: TextStyle(
                  fontSize: hi / 62, color: theme.textTheme.bodyMedium!.color)),
        ],
      ),
    );
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
  }
}
