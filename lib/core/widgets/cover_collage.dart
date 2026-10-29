import 'package:flutter/material.dart';

import '../theme/app_radii.dart';
import '../theme/app_sizes.dart';
import 'cover_art.dart';

class CoverCollage extends StatelessWidget {
  const CoverCollage({
    super.key,
    required this.seeds,
    this.size = AppSizes.songCover,
    this.radius = AppRadii.thumb,
  });

  final List<String> seeds;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    if (seeds.isEmpty) {
      return CoverArt(seed: '', size: size, radius: radius);
    }
    final half = size / 2;
    // Fewer than four seeds repeat, so the 2x2 grid is always full.
    Widget cell(int index) {
      return CoverArt(seed: seeds[index % seeds.length], size: half, radius: 0);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox.square(
        dimension: size,
        child: Column(
          children: [
            Row(children: [cell(0), cell(1)]),
            Row(children: [cell(2), cell(3)]),
          ],
        ),
      ),
    );
  }
}
