import 'package:flutter/material.dart';

import '../../../core/app/app_name.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/logo_mark.dart';
import '../../../core/widgets/round_icon_button.dart';

class InfoHeader extends StatelessWidget {
  const InfoHeader({super.key, required this.title, this.lastUpdated});

  final String title;
  final String? lastUpdated;

  static const double _logoSize = 84;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final updated = lastUpdated;
    // Stretch matches the full-width layout these pieces had as ListView items.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: RoundIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            tooltip: 'Back',
            onPressed: () => Navigator.maybePop(context),
          ),
        ),
        const SizedBox(height: 16),
        const Center(child: LogoMark(size: _logoSize)),
        const SizedBox(height: 16),
        Text(appName.toUpperCase(),
            textAlign: TextAlign.center, style: text.labelSmall),
        const SizedBox(height: 4),
        Text(title, textAlign: TextAlign.center, style: text.headlineLarge),
        if (updated != null) ...[
          const SizedBox(height: 6),
          Text(
            updated,
            textAlign: TextAlign.center,
            style:
                text.bodyMedium?.copyWith(color: AppTokens.of(context).text2),
          ),
        ],
      ],
    );
  }
}
