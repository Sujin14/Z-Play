import 'package:flutter/material.dart';

import '../../../core/widgets/logo_mark.dart';
import '../../../core/widgets/round_icon_button.dart';

class InfoHeader extends StatelessWidget {
  const InfoHeader({super.key, required this.title});

  final String title;

  static const double _logoSize = 84;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
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
        Text('Z-PLAY', textAlign: TextAlign.center, style: text.labelSmall),
        const SizedBox(height: 4),
        Text(title, textAlign: TextAlign.center, style: text.headlineLarge),
      ],
    );
  }
}
