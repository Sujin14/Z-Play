import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_sizes.dart';

class CoverArt extends StatelessWidget {
  const CoverArt({
    super.key,
    required this.seed,
    this.image,
    this.size = AppSizes.songCover,
    this.radius = AppRadii.thumb,
    this.circle = false,
    this.child,
  });

  final String seed;
  final ImageProvider? image;
  final double size;
  final double radius;
  final bool circle;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final shape = circle
        ? const CircleBorder()
        : RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));
    return SizedBox.square(
      dimension: size,
      child: ClipPath(
        clipper: ShapeBorderClipper(shape: shape),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (image != null)
              Image(
                image: image!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _FallbackTile(seed: seed),
              )
            else
              _FallbackTile(seed: seed),
            if (child != null) Center(child: child),
          ],
        ),
      ),
    );
  }
}

class _FallbackTile extends StatelessWidget {
  const _FallbackTile({required this.seed});

  final String seed;

  static const _highlightCenter = Alignment(-0.7, -0.7);
  static const double _highlightRadius = 0.9;
  static const _hashMultiplier = 31;
  static const _hashMask = 0x7fffffff;

  // Stable across runs, unlike String.hashCode, so a song keeps its tile.
  static List<Color> _colorsFor(String seed) {
    var hash = 0;
    for (final unit in seed.codeUnits) {
      hash = (hash * _hashMultiplier + unit) & _hashMask;
    }
    return AppColors.covers[hash % AppColors.covers.length];
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _colorsFor(seed),
        ),
      ),
      child: const DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: _highlightCenter,
            radius: _highlightRadius,
            colors: [Color(0x4DFFFFFF), Color(0x00FFFFFF)], // white 30%
          ),
        ),
      ),
    );
  }
}
