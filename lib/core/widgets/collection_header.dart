import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_tokens.dart';
import 'play_shuffle_buttons.dart';

class CollectionHeader extends StatelessWidget {
  const CollectionHeader({
    super.key,
    required this.cover,
    required this.title,
    required this.subtitle,
    required this.onPlayAll,
    required this.onShuffle,
    this.circle = false,
  });

  // Drawn at 176x176; clip it to radius, or to a circle when circle is set.
  final Widget cover;
  final String title;
  final String subtitle;
  final VoidCallback? onPlayAll;
  final VoidCallback? onShuffle;
  final bool circle;

  static const double size = 176;
  static const double radius = 28;

  static const double _glowAlpha = 0.28;
  static const double _glowBlur = 48;
  static const double _glowSpread = -4;
  static const Offset _glowOffset = Offset(0, 12);

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen, 20, AppSpacing.screen, 12),
      child: Column(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              shape: circle ? BoxShape.circle : BoxShape.rectangle,
              borderRadius: circle ? null : BorderRadius.circular(radius),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neon.withValues(alpha: _glowAlpha),
                  blurRadius: _glowBlur,
                  spreadRadius: _glowSpread,
                  offset: _glowOffset,
                ),
              ],
            ),
            child: SizedBox.square(dimension: size, child: cover),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: text.headlineMedium,
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: text.bodyLarge?.copyWith(color: AppTokens.of(context).text2),
          ),
          const SizedBox(height: 24),
          PlayShuffleButtons(onPlayAll: onPlayAll, onShuffle: onShuffle),
        ],
      ),
    );
  }
}
