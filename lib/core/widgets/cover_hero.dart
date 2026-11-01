import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../navigation/mini_player_anchor.dart';
import '../navigation/now_playing_route.dart';
import 'cover_art.dart';

// The cover that flies between the mini player and Now Playing. Only the art
// flies; anything drawn on top of it (the Lottie) stays on its page, so its
// animation never restarts mid-flight.
class CoverHero extends StatelessWidget {
  const CoverHero({
    super.key,
    required this.seed,
    required this.size,
    required this.radius,
    this.image,
  });

  final String seed;
  final ImageProvider? image;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: MiniPlayerAnchor.coverHeroTag,
      curve: NowPlayingRoute.curve,
      transitionOnUserGestures: true,
      flightShuttleBuilder: _shuttle,
      child: CoverArt(seed: seed, image: image, size: size, radius: radius),
    );
  }

  // The animation is Now Playing's in both directions (1 = fully open), so
  // the corner radius always runs from the small cover's to the large one's.
  static Widget _shuttle(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection direction,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    final from = fromHeroContext.findAncestorWidgetOfExactType<CoverHero>()!;
    final to = toHeroContext.findAncestorWidgetOfExactType<CoverHero>()!;
    final push = direction == HeroFlightDirection.push;
    final small = push ? from : to;
    final large = push ? to : from;
    // The large art scaled to the flight rect, so it never stretches and
    // nothing rebuilds per frame except the clip radius.
    return AnimatedBuilder(
      animation: animation,
      child: FittedBox(
        fit: BoxFit.cover,
        child: CoverArt(
            seed: large.seed, image: large.image, size: large.size, radius: 0),
      ),
      builder: (context, child) => ClipRRect(
        borderRadius: BorderRadius.circular(
            lerpDouble(small.radius, large.radius, animation.value)!),
        child: child,
      ),
    );
  }
}
