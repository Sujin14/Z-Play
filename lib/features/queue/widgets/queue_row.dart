import 'package:flutter/material.dart';

import '../../../core/models/song_model.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/cover_art.dart';

class QueueRow extends StatelessWidget {
  const QueueRow({
    super.key,
    required this.song,
    required this.index,
    required this.onTap,
    required this.onRemove,
  });

  final Song song;
  // Position inside the section's reorderable list, for the drag handle.
  final int index;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  static const double _radius = 18;
  static const double _handleHeight = 48;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    final text = Theme.of(context).textTheme;
    return InkWell(
      borderRadius: BorderRadius.circular(_radius),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 6, 0, 6),
        child: Row(
          children: [
            // The handle drags immediately; the rest of the row needs a long press.
            ReorderableDragStartListener(
              index: index,
              child: SizedBox(
                width: AppSizes.touchTarget,
                height: _handleHeight,
                child: Icon(Icons.drag_handle_rounded, color: tokens.text2),
              ),
            ),
            CoverArt(seed: song.title, size: AppSizes.songCover),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleMedium),
                  const SizedBox(height: 2),
                  Text(song.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodyMedium),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Remove from queue',
              onPressed: onRemove,
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
