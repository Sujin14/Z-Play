import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/navigation/app_router.dart';
import '../../../core/navigation/navigation_service.dart';
import '../../../core/state/player_view_model.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/gradient_scaffold.dart';
import '../../../core/widgets/minimize_drag_area.dart';
import '../view_model/player_screen_view_model.dart';
import '../widgets/now_playing_cover.dart';
import '../widgets/playback_controls.dart';
import '../widgets/player_action_bar.dart';
import '../widgets/player_error_line.dart';
import '../widgets/player_title_row.dart';
import '../widgets/player_top_bar.dart';
import '../widgets/seek_bar.dart';
import '../widgets/up_next_pill.dart';

class PlayerView extends StatelessWidget {
  const PlayerView({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerViewModel>();
    final screen = PlayerScreenViewModel(player);
    final song = screen.song;
    return GradientScaffold(
      body: SafeArea(
        child: song == null
            ? const Column(
                children: [
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: AppSpacing.screen),
                    child: MinimizeDragArea(
                      child: PlayerTopBar(fromLine: null),
                    ),
                  ),
                  Expanded(
                    child: EmptyState(
                      icon: Icons.music_note_rounded,
                      title: 'Nothing is playing.',
                      message:
                          'Pick a song from your library to start listening.',
                    ),
                  ),
                ],
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  final next = screen.nextSong;
                  // Fills the screen when there is room; scrolls instead of
                  // overflowing on very short screens.
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                            AppSpacing.screen, 0, AppSpacing.screen, 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            MinimizeDragArea(
                              child: PlayerTopBar(fromLine: screen.fromLine),
                            ),
                            MinimizeDragArea(
                              child: NowPlayingCover(
                                  player: player,
                                  song: song,
                                  size: screen.coverSize(constraints)),
                            ),
                            PlayerTitleRow(song: song),
                            SeekBar(player: player),
                            if (screen.error != null)
                              PlayerErrorLine(message: screen.error!),
                            PlaybackControls(
                              player: player,
                              shuffleTooltip: screen.shuffleTooltip,
                              repeatTooltip: screen.repeatTooltip,
                              repeatActive: screen.repeatActive,
                            ),
                            PlayerActionBar(
                              player: player,
                              song: song,
                              speedLabel: screen.speedLabel,
                              sleepActive: screen.isSleepActive,
                            ),
                            if (next == null)
                              const SizedBox.shrink()
                            else
                              UpNextPill(
                                coverSeed: next.title,
                                label: screen.nextLabel(next),
                                onTap: () => NavigationService.pushNamed(
                                    AppRoutes.queue),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
