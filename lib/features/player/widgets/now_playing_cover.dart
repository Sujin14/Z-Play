import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../core/models/song_model.dart';
import '../../../core/state/player_view_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/widgets/cover_hero.dart';

class NowPlayingCover extends StatefulWidget {
  const NowPlayingCover(
      {super.key,
      required this.player,
      required this.song,
      required this.size});

  final PlayerViewModel player;
  final Song song;
  final double size;

  @override
  State<NowPlayingCover> createState() => _NowPlayingCoverState();
}

class _NowPlayingCoverState extends State<NowPlayingCover>
    with SingleTickerProviderStateMixin {
  late final AnimationController _lottie = AnimationController(
    vsync: this,
    duration: _lottieCycle,
  );

  static const _lottieCycle = Duration(seconds: 5);
  static const double _lottieScale = 0.7;
  static const double _glowAlpha = 0.3;
  static const double _glowBlur = 60;
  static const double _glowSpread = -6;
  static const Offset _glowOffset = Offset(0, 16);
  // The Lottie shows once the flying cover has landed under it.
  static const _lottieReveal = Interval(0.8, 1);

  CurvedAnimation? _lottieFade;

  @override
  void initState() {
    super.initState();
    widget.player.addListener(_syncLottie);
    _syncLottie();
  }

  @override
  void didUpdateWidget(NowPlayingCover oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (identical(oldWidget.player, widget.player)) return;
    oldWidget.player.removeListener(_syncLottie);
    widget.player.addListener(_syncLottie);
    _syncLottie();
  }

  // Loops only while playing; pausing freezes the animation where it is.
  void _syncLottie() {
    if (!mounted) return;
    final playing = widget.player.isPlaying;
    if (playing && !_lottie.isAnimating) {
      _lottie.repeat();
    } else if (!playing && _lottie.isAnimating) {
      _lottie.stop();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeAnimation = ModalRoute.of(context)?.animation;
    if (routeAnimation == null || _lottieFade?.parent == routeAnimation) {
      return;
    }
    _lottieFade?.dispose();
    _lottieFade = CurvedAnimation(parent: routeAnimation, curve: _lottieReveal);
  }

  @override
  void dispose() {
    widget.player.removeListener(_syncLottie);
    _lottieFade?.dispose();
    _lottie.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // No artwork source exists yet; once one does, pass it here and the
    // Lottie is left off automatically.
    const ImageProvider? artwork = null;
    final size = widget.size;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.nowPlaying),
        boxShadow: [
          BoxShadow(
            color: AppColors.neon.withValues(alpha: _glowAlpha),
            blurRadius: _glowBlur,
            spreadRadius: _glowSpread,
            offset: _glowOffset,
          ),
        ],
      ),
      // Only the art is the hero; the Lottie stays on this page, so the
      // flight never re-mounts it and its loop never restarts.
      child: Stack(
        alignment: Alignment.center,
        children: [
          CoverHero(
            seed: widget.song.title,
            image: artwork,
            size: size,
            radius: AppRadii.nowPlaying,
          ),
          if (artwork == null)
            FadeTransition(
              opacity: _lottieFade ?? kAlwaysCompleteAnimation,
              child: Lottie.asset(
                'assets/json/music_player.json',
                controller: _lottie,
                width: size * _lottieScale,
                height: size * _lottieScale,
                fit: BoxFit.contain,
              ),
            ),
        ],
      ),
    );
  }
}
