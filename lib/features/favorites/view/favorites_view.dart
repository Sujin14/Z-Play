import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/song_actions.dart';
import '../../../core/state/library_view_model.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/song_sliver_list.dart';
import '../view_model/favorites_view_model.dart';
import '../widgets/favorites_header.dart';
import '../widgets/favorites_summary_card.dart';

class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = FavoritesViewModel(context.watch<LibraryViewModel>());
    final songs = favorites.songs;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: FavoritesHeader()),
            if (favorites.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.paddingOf(context).bottom),
                  child: const EmptyState(
                    scrollable: false,
                    icon: Icons.favorite_border_rounded,
                    title: 'No favorite songs yet.',
                    message: 'Tap ⋮ on any song and choose Add to favorites.',
                  ),
                ),
              )
            else ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screen, 20, AppSpacing.screen, 12),
                  child: FavoritesSummaryCard(
                    count: favorites.countLabel,
                    duration: favorites.durationLabel,
                    onPlayAll: () => playAll(context, songs),
                    onShuffle: () => shuffleAll(context, songs),
                  ),
                ),
              ),
              SongSliverList(songs: songs, showFavoriteHeart: false),
              SliverToBoxAdapter(
                child:
                    SizedBox(height: 8 + MediaQuery.paddingOf(context).bottom),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
