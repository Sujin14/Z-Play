import 'package:flutter/material.dart';

import '../theme/app_sizes.dart';
import '../theme/app_spacing.dart';
import 'round_icon_button.dart';

class DetailTopBar extends StatelessWidget {
  const DetailTopBar({super.key, required this.eyebrow, this.trailing});

  final String eyebrow;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen, 12, AppSpacing.screen, 0),
      child: Row(
        children: [
          RoundIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            tooltip: 'Back',
            onPressed: () => Navigator.maybePop(context),
          ),
          Expanded(
            child: Text(
              eyebrow.toUpperCase(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          // Same width as the back button keeps the eyebrow centered.
          trailing ?? const SizedBox(width: AppSizes.roundButton),
        ],
      ),
    );
  }
}
