import 'package:flutter/material.dart';

import '../../../core/app/app_name.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_tokens.dart';

class FavoritesHeader extends StatelessWidget {
  const FavoritesHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen, 16, AppSpacing.screen, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appName.toUpperCase(), style: text.labelSmall),
                const SizedBox(height: 4),
                Text('Favorites', style: text.headlineLarge),
              ],
            ),
          ),
          // Decorative badge, so screen readers skip it.
          ExcludeSemantics(
            child: Container(
              width: AppSizes.roundButton,
              height: AppSizes.roundButton,
              decoration: BoxDecoration(
                color: tokens.card,
                shape: BoxShape.circle,
                border: Border.all(color: tokens.line),
              ),
              child: Icon(Icons.favorite_rounded, color: tokens.heart),
            ),
          ),
        ],
      ),
    );
  }
}
