import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/music_viewmodel.dart';
import 'mini_player_slider.dart';
import 'mini_player_controls.dart';
import 'package:lottie/lottie.dart';

class MiniPlayerContainer extends StatelessWidget {
  const MiniPlayerContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final musicVM = Provider.of<MusicViewModel>(context);
    final musicFile = musicVM.currentMusicFile!;

    return Container(
      height: 92,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MiniPlayerSlider(musicViewModel: musicVM),
          Row(
            children: [
              Lottie.asset(
                'assets/json/music_wave.json',
                height: 35,
                width: 35,
                animate: musicVM.isPlaying,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  musicFile.title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.95),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              MiniPlayerControls(musicViewModel: musicVM),
            ],
          ),
        ],
      ),
    );
  }
}
