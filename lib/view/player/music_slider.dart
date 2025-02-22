import 'package:flutter/material.dart';
import 'package:musicplayer/view_model/providers/music_provider.dart';

class MusicSlider extends StatelessWidget {
  final MusicProvider musicProvider;
  final double hi;
  final double wi;

  const MusicSlider(
      {super.key,
      required this.musicProvider,
      required this.hi,
      required this.wi});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF54565C),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(formatDuration(musicProvider.currentPosition),
              style: TextStyle(fontSize: hi / 60)),
          SizedBox(
            width: wi / 1.5,
            child: Slider(
              inactiveColor: Colors.white,
              activeColor: Colors.green,
              thumbColor: Colors.black,
              value: musicProvider.currentPosition.inSeconds.toDouble(),
              max: musicProvider.totalDuration.inSeconds.toDouble(),
              onChanged: (value) {
                musicProvider.seekMusic(Duration(seconds: value.toInt()));
              },
            ),
          ),
          Text(formatDuration(musicProvider.totalDuration),
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
