import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/music_viewmodel.dart';
import '../widgets/music_animation.dart';
import '../widgets/music_controls.dart';
import '../widgets/music_slider.dart';
import '../../domain/entities/music_file_entity.dart';
import '../../../../constants/themes.dart';

class MusicPlayer extends StatefulWidget {
  final MusicFileEntity musicFile;
  final List<MusicFileEntity> playlist;

  const MusicPlayer({
    super.key,
    required this.musicFile,
    required this.playlist,
  });

  @override
  State<MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer>
    with TickerProviderStateMixin {
  late AnimationController _lottieController;

  @override
  void initState() {
    super.initState();
    _lottieController =
        AnimationController(vsync: this, duration: const Duration(seconds: 5));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final musicVM = Provider.of<MusicViewModel>(context, listen: false);
      musicVM.playMusic(widget.musicFile, widget.playlist,
          widget.playlist.indexOf(widget.musicFile));
      if (musicVM.isPlaying) _lottieController.repeat();
    });
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = MediaQuery.of(context).size.height;
    final wi = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final musicVM = Provider.of<MusicViewModel>(context);

    if (musicVM.isPlaying) {
      _lottieController.repeat();
    } else {
      _lottieController.stop();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          musicVM.currentMusicFile?.title ?? 'Loading...',
          style: style(fontSize: hi / 45, color: theme.textTheme.bodyLarge!.color),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.colorScheme.gradientStart, theme.colorScheme.gradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              // Music animation
              MusicAnimation(
                  lottieController: _lottieController, hi: hi, wi: wi),
              SizedBox(height: hi / 80),
              // Music slider
              MusicSlider(musicViewModel: musicVM, hi: hi, wi: wi),
              SizedBox(height: hi / 70),

              // Music controls
              MusicControls(hi: hi),
            ],
          ),
        ),
      ),
    );
  }
}