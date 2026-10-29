import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/song_actions.dart';
import '../../../core/state/library_view_model.dart';
import '../../../core/state/player_view_model.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/gradient_scaffold.dart';
import '../../../core/widgets/song_menu_sheet.dart';
import '../../../core/widgets/song_tile.dart';
import '../view_model/history_view_model.dart';
import '../widgets/count_pill.dart';
import '../widgets/history_header.dart';
import '../widgets/rank_number.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key, required this.kind});

  // Segment shown first; the screen can switch between both.
  final HistoryKind kind;

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  late HistoryKind _kind = widget.kind;

  @override
  Widget build(BuildContext context) {
    final history = HistoryViewModel(
      library: context.watch<LibraryViewModel>(),
      player: context.watch<PlayerViewModel>(),
      kind: _kind,
    );
    final songs = history.songs;
    return GradientScaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: HistoryHeader(
                title: history.title,
                kind: _kind,
                onKindChanged: (kind) => setState(() => _kind = kind),
              ),
            ),
            if (songs.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  scrollable: false,
                  icon: history.emptyIcon,
                  title: history.emptyTitle,
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.list,
                  0,
                  AppSpacing.list,
                  24 + MediaQuery.paddingOf(context).bottom,
                ),
                sliver: SliverList.builder(
                  itemCount: songs.length,
                  itemBuilder: (context, index) {
                    final song = songs[index];
                    final rank = history.rankAt(index);
                    final pill = history.pillFor(song);
                    return SongTile(
                      song: song,
                      favorite: history.isFavorite(song),
                      current: history.isCurrent(song),
                      playing: history.isPlaying(song),
                      leading: rank == null
                          ? null
                          : RankNumber(
                              rank: rank,
                              highlighted: history.isHighlightedRank(rank)),
                      trailing: pill == null ? null : CountPill(pill),
                      onTap: () => playFromList(context, songs, index),
                      onMore: () => showSongMenu(context, song),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
