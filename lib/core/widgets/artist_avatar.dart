import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/text_utils.dart';
import 'cover_art.dart';

class ArtistAvatar extends StatelessWidget {
  const ArtistAvatar({super.key, required this.name, required this.size});

  final String name;
  final double size;

  static const double _initialScale = 0.34;
  static const double _initialAlpha = 0.75;

  @override
  Widget build(BuildContext context) {
    return CoverArt(
      seed: name,
      size: size,
      circle: true,
      child: Text(
        artistInitial(name),
        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontSize: size * _initialScale,
              color: AppColors.onAccent.withValues(alpha: _initialAlpha),
            ),
      ),
    );
  }
}
