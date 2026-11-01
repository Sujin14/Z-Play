import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/round_icon_button.dart';

class HiddenFoldersHeader extends StatelessWidget {
  const HiddenFoldersHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen, 12, AppSpacing.screen, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RoundIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            tooltip: 'Back',
            onPressed: () => Navigator.maybePop(context),
          ),
          const SizedBox(height: 20),
          Text('Hidden folders', style: text.headlineLarge),
          const SizedBox(height: 4),
          Text(
            'Songs in these folders don\'t appear in your library.',
            style: text.bodyLarge?.copyWith(color: AppTokens.of(context).text2),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
