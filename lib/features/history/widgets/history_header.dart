import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/round_icon_button.dart';
import '../model/segment_option_model.dart';
import '../view_model/history_view_model.dart';
import 'segmented_pill.dart';

class HistoryHeader extends StatelessWidget {
  const HistoryHeader({
    super.key,
    required this.title,
    required this.kind,
    required this.onKindChanged,
  });

  final String title;
  final HistoryKind kind;
  final ValueChanged<HistoryKind> onKindChanged;

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
          Text('LISTENING HISTORY', style: text.labelSmall),
          const SizedBox(height: 4),
          Text(title, style: text.headlineLarge),
          const SizedBox(height: 20),
          SegmentedPill<HistoryKind>(
            selected: kind,
            onChanged: onKindChanged,
            segments: const [
              SegmentOption(
                value: HistoryKind.recent,
                label: 'Recently played',
                icon: Icons.history_rounded,
              ),
              SegmentOption(
                value: HistoryKind.mostPlayed,
                label: 'Most played',
                icon: Icons.trending_up_rounded,
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
