import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/state/player_view_model.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/gradient_scaffold.dart';
import '../../../core/widgets/playlist_editor_sheet.dart';
import '../view_model/queue_view_model.dart';
import '../widgets/now_playing_card.dart';
import '../widgets/queue_header.dart';
import '../widgets/queue_section.dart';
import '../widgets/queue_section_label.dart';

class QueueView extends StatelessWidget {
  const QueueView({super.key});

  @override
  Widget build(BuildContext context) {
    final queue = QueueViewModel(context.watch<PlayerViewModel>());
    final songs = queue.songs;
    final text = Theme.of(context).textTheme;
    return GradientScaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: QueueHeader(
                subtitle: queue.isEmpty ? null : queue.subtitle,
                onSave: queue.isEmpty
                    ? null
                    : () => showPlaylistEditor(context, initialSongs: songs),
              ),
            ),
            if (queue.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  scrollable: false,
                  icon: Icons.queue_music_rounded,
                  title: 'The queue is empty.',
                  message: 'Play a song or add one with Add to queue.',
                ),
              )
            else ...[
              if (queue.hasCurrent) ...[
                const QueueSectionLabel('Now playing'),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screen),
                    child: NowPlayingCard(
                      song: queue.current,
                      player: queue.player,
                      onTap: queue.jumpToCurrent,
                      onRemove: queue.removeCurrent,
                    ),
                  ),
                ),
              ],
              if (queue.upNextCount > 0) ...[
                const QueueSectionLabel('Up next'),
                QueueSection(
                    queue: queue,
                    start: queue.upNextStart,
                    count: queue.upNextCount),
              ],
              if (queue.earlierCount > 0) ...[
                const QueueSectionLabel('Earlier in queue'),
                QueueSection(queue: queue, start: 0, count: queue.earlierCount),
              ],
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.screen,
                    20,
                    AppSpacing.screen,
                    20 + MediaQuery.paddingOf(context).bottom,
                  ),
                  child: Text(
                    'Hold a song and drag to reorder',
                    textAlign: TextAlign.center,
                    style: text.bodyMedium,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
