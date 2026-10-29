import 'package:flutter/material.dart';

import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/cover_art.dart';

class UpNextPill extends StatelessWidget {
  const UpNextPill({
    super.key,
    required this.coverSeed,
    required this.label,
    required this.onTap,
  });

  final String coverSeed;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    final text = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(AppRadii.miniPlayer);
    return Material(
      color: tokens.card,
      shape: RoundedRectangleBorder(
          borderRadius: radius, side: BorderSide(color: tokens.line)),
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
          child: Row(
            children: [
              CoverArt(
                  seed: coverSeed,
                  size: AppSizes.smallCover,
                  radius: AppRadii.small),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('UP NEXT',
                        style: text.labelSmall?.copyWith(color: tokens.text2)),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleSmall,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: tokens.text2),
            ],
          ),
        ),
      ),
    );
  }
}
