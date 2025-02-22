import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class MusicAnimation extends StatelessWidget {
  final AnimationController lottieController;
  final double hi;
  final double wi;

  const MusicAnimation(
      {super.key,
      required this.lottieController,
      required this.hi,
      required this.wi});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: hi / 2.2,
      child: Lottie.asset(
        'assets/json/music_player.json',
        height: hi - 120,
        width: wi,
        fit: BoxFit.contain,
        controller: lottieController,
      ),
    );
  }
}
