import 'package:flutter/material.dart';

import '../theme/app_radii.dart';
import 'cover_art.dart';

class AlbumCover extends StatelessWidget {
  const AlbumCover({
    super.key,
    required this.seed,
    required this.size,
    this.radius = AppRadii.album,
  });

  final String seed;
  final double size;
  final double radius;

  // The disc mark hangs off the bottom-right corner and is clipped by it.
  static const double _discOverhang = 0.12;
  static const double _discSize = 0.55;
  static const double _discAlpha = 0.14;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          children: [
            CoverArt(seed: seed, size: size, radius: 0),
            Positioned(
              right: -size * _discOverhang,
              bottom: -size * _discOverhang,
              child: Icon(
                Icons.album_outlined,
                size: size * _discSize,
                color: Colors.black.withValues(alpha: _discAlpha),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
