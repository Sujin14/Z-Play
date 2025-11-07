import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/music_file_entity.dart';
import '../../../../constants/themes.dart';
import '../viewmodels/music_viewmodel.dart';
import '../widgets/music_player/music_animation.dart';
import '../widgets/music_player/music_slider.dart';
import '../widgets/music_player/music_controls.dart';

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

      if (musicVM.currentMusicFile?.path != widget.musicFile.path) {
        musicVM.playMusic(widget.musicFile, widget.playlist,
            widget.playlist.indexOf(widget.musicFile));
      }

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

    musicVM.isPlaying ? _lottieController.repeat() : _lottieController.stop();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          musicVM.currentMusicFile?.title ?? 'Loading...',
          style:
              style(fontSize: hi / 45, color: theme.textTheme.bodyLarge!.color),
        ),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.gradientStart,
              theme.colorScheme.gradientEnd
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                _buildCoverArt(theme, hi, wi),
                SizedBox(height: hi / 50),
                _buildSongInfo(theme, musicVM, hi),
                SizedBox(height: hi / 50),
                MusicSlider(musicViewModel: musicVM, hi: hi, wi: wi),
                SizedBox(height: hi / 50),
                MusicControls(hi: hi),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoverArt(ThemeData theme, double hi, double wi) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Stack(
        children: [
          Container(
            height: hi / 2.6,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withOpacity(0.12),
                  theme.colorScheme.tertiary.withOpacity(0.10)
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(color: Colors.transparent),
            ),
          ),
          Center(
            child: MusicAnimation(
              lottieController: _lottieController,
              hi: hi,
              wi: wi,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSongInfo(ThemeData theme, MusicViewModel musicVM, double hi) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.glassFill,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.colorScheme.glassBorder),
          ),
          child: Text(
            musicVM.currentMusicFile?.title ?? '',
            style: style(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: theme.textTheme.bodyLarge!.color,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
