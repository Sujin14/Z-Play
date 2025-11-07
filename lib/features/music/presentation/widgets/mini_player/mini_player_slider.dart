import 'package:flutter/material.dart';
import '../../viewmodels/music_viewmodel.dart';

class MiniPlayerSlider extends StatelessWidget {
  final MusicViewModel musicViewModel;

  const MiniPlayerSlider({super.key, required this.musicViewModel});

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 2.5,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
        thumbColor: Colors.white,
        activeTrackColor: Colors.white.withOpacity(0.9),
        inactiveTrackColor: Colors.white.withOpacity(0.2),
      ),
      child: Slider(
        value: musicViewModel.currentPosition.inSeconds.toDouble(),
        max: musicViewModel.totalDuration.inSeconds.toDouble(),
        onChanged: (value) {
          musicViewModel.seekMusic(Duration(seconds: value.toInt()));
        },
      ),
    );
  }
}
