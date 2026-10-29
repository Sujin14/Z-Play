import 'package:flutter/material.dart';

import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_tokens.dart';
import '../model/info_page_model.dart';

class InfoSectionCard extends StatelessWidget {
  const InfoSectionCard({super.key, required this.section});

  final InfoSection section;

  static const double _headingSize = 17;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: tokens.card,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: tokens.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(section.heading,
              style: text.titleMedium?.copyWith(
                  fontSize: _headingSize, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(section.body,
              style: text.bodyLarge?.copyWith(color: tokens.text2)),
        ],
      ),
    );
  }
}
