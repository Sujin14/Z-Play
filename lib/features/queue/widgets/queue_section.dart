import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_tokens.dart';
import '../view_model/queue_view_model.dart';
import 'queue_row.dart';

class QueueSection extends StatelessWidget {
  const QueueSection({
    super.key,
    required this.queue,
    required this.start,
    required this.count,
  });

  final QueueViewModel queue;
  final int start;
  final int count;

  static const double _dragRadius = 18;
  static const double _dragElevation = 12;
  static const double _dragAlpha = 0.96;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.list),
      sliver: SliverReorderableList(
        itemCount: count,
        onReorderItem: (oldIndex, newIndex) =>
            queue.reorderWithin(start, oldIndex, newIndex),
        proxyDecorator: (child, index, animation) => AnimatedBuilder(
          animation: animation,
          child: child,
          builder: (context, child) => Material(
            color: tokens.sheet.withValues(alpha: _dragAlpha),
            elevation: _dragElevation * animation.value,
            shadowColor: Colors.black54,
            borderRadius: BorderRadius.circular(_dragRadius),
            child: child,
          ),
        ),
        itemBuilder: (context, index) {
          final position = queue.positionIn(start, index);
          final song = queue.songs[position];
          return ReorderableDelayedDragStartListener(
            key: ValueKey('${song.path}-$position'),
            index: index,
            child: QueueRow(
              song: song,
              index: index,
              onTap: () => queue.jumpTo(position),
              onRemove: () => queue.remove(position),
            ),
          );
        },
      ),
    );
  }
}
