import 'package:flutter/material.dart';
import '../../viewmodels/music_viewmodel.dart';

class MiniPlayerControls extends StatelessWidget {
  final MusicViewModel musicViewModel;

  const MiniPlayerControls({super.key, required this.musicViewModel});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.skip_previous_rounded),
          color: Colors.white.withOpacity(0.9),
          onPressed: musicViewModel.playPrevious,
        ),
        GestureDetector(
          onTap: () {
            if (musicViewModel.isPlaying) {
              musicViewModel.pauseMusic();
            } else {
              musicViewModel.resumeMusic();
            }
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF9C27B0), Color(0xFF2196F3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.purpleAccent.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(
              musicViewModel.isPlaying
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.skip_next_rounded),
          color: Colors.white.withOpacity(0.9),
          onPressed: musicViewModel.playNext,
        ),
      ],
    );
  }
}
