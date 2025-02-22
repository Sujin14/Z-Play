import 'package:flutter/material.dart';
import 'package:musicplayer/model/model.dart';
import 'package:musicplayer/view/player/music_animations.dart';
import 'package:musicplayer/view/player/player_controls.dart';
import 'package:musicplayer/view_model/providers/music_provider.dart';
import 'package:provider/provider.dart';
import 'music_slider.dart';
import 'music_controls.dart';

class MusicPlayer extends StatefulWidget {
  final MusicFile musicFile;
  final List<MusicFile> playlist;

  const MusicPlayer(
      {super.key, required this.musicFile, required this.playlist});

  @override
  State<MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer>
    with TickerProviderStateMixin {
  late MusicController musicController;
  late AnimationController _lottieController;

  @override
  void initState() {
    super.initState();
    int currentIndex = widget.playlist.indexOf(widget.musicFile);
    musicController =
        MusicController(playlist: widget.playlist, currentIndex: currentIndex);
    musicController.init(context);
    _lottieController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    final musicProvider = Provider.of<MusicProvider>(context);
    final double hi = MediaQuery.of(context).size.height;
    final double wi = MediaQuery.of(context).size.width;

    if (musicProvider.isPlaying) {
      _lottieController.repeat();
    } else {
      _lottieController.stop();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          musicProvider.currentMusicFile!.title,
          style: TextStyle(fontSize: hi / 45, color: Colors.white),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF28286E), Color(0xFF727375)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              MusicAnimation(
                  lottieController: _lottieController,
                  hi: hi,
                  wi: wi), // Pass hi & wi
              SizedBox(height: hi / 70),
              MusicSlider(
                  musicProvider: musicProvider,
                  hi: hi,
                  wi: wi), // Pass required parameters
              SizedBox(height: hi / 70),
              MusicControls(
                  musicController: musicController,
                  musicProvider: musicProvider,
                  hi: hi), // Pass musicProvider
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _lottieController.dispose();
    musicController.dispose();
    super.dispose();
  }
}
