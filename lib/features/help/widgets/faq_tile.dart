import 'package:flutter/material.dart';

import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_tokens.dart';
import '../model/faq_item.dart';

class FaqTile extends StatelessWidget {
  const FaqTile({
    super.key,
    required this.item,
    required this.open,
    required this.onTap,
  });

  final FaqItem item;
  final bool open;
  final VoidCallback onTap;

  static const _expandDuration = Duration(milliseconds: 260);

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    final text = Theme.of(context).textTheme;
    return Material(
      color: tokens.glass,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
        side: BorderSide(color: tokens.line),
      ),
      child: Column(
        children: [
          Semantics(
            button: true,
            expanded: open,
            child: InkWell(
              onTap: onTap,
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(minHeight: AppSizes.touchTarget),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(item.question, style: text.titleMedium),
                      ),
                      const SizedBox(width: 12),
                      AnimatedRotation(
                        turns: open ? 0.5 : 0,
                        duration: _expandDuration,
                        curve: Curves.easeOutCubic,
                        child: Icon(Icons.expand_more_rounded,
                            color: tokens.accentText),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: _expandDuration,
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: open
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(item.answer,
                          style: text.bodyLarge?.copyWith(color: tokens.text2)),
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}
