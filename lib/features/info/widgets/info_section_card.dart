import 'package:flutter/material.dart';

import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/ghost_button.dart';
import '../model/info_page_model.dart';

class InfoSectionCard extends StatelessWidget {
  const InfoSectionCard({super.key, required this.section, this.onAction});

  final InfoSection section;
  final VoidCallback? onAction;

  static const double _headingSize = 17;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    final text = Theme.of(context).textTheme;
    final body = text.bodyLarge?.copyWith(color: tokens.text2);
    final heading = section.heading;
    final action = section.action;
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
          SelectionArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (heading != null)
                  Text(heading,
                      style: text.titleMedium?.copyWith(
                          fontSize: _headingSize, fontWeight: FontWeight.w700)),
                for (final (index, block) in section.blocks.indexed) ...[
                  if (index > 0 || heading != null) const SizedBox(height: 8),
                  switch (block) {
                    InfoParagraph(:final text) => Text(text, style: body),
                    InfoBullets(:final items) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final item in items)
                            _Bullet(text: item, style: body),
                        ],
                      ),
                  },
                ],
              ],
            ),
          ),
          if (action != null) ...[
            const SizedBox(height: 14),
            GhostButton(
              label: action.label,
              icon: Icons.article_outlined,
              accent: true,
              onPressed: onAction,
            ),
          ],
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text, required this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    // The dot uses the body style so it lines up with the first line of text.
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('•',
              style: style?.copyWith(
                  color: AppTokens.of(context).accentText,
                  fontWeight: FontWeight.w700)),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: style)),
        ],
      ),
    );
  }
}
