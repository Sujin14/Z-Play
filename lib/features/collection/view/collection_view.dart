import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/collection_args_model.dart';
import '../../../core/services/song_actions.dart';
import '../../../core/state/library_view_model.dart';
import '../../../core/widgets/collection_header.dart';
import '../../../core/widgets/detail_top_bar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/gradient_scaffold.dart';
import '../../../core/widgets/song_sliver_list.dart';
import '../view_model/collection_view_model.dart';
import '../widgets/collection_cover.dart';

class CollectionView extends StatelessWidget {
  const CollectionView({super.key, required this.args});

  final CollectionArgs args;

  @override
  Widget build(BuildContext context) {
    final collection =
        CollectionViewModel(context.watch<LibraryViewModel>(), args);
    final songs = collection.songs;
    final hasSongs = collection.hasSongs;
    return GradientScaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
                child: DetailTopBar(eyebrow: collection.eyebrow)),
            SliverToBoxAdapter(
              child: CollectionHeader(
                cover: CollectionCover(
                    kind: collection.kind, title: collection.title),
                circle: collection.isArtist,
                title: collection.title,
                subtitle: collection.subtitle,
                onPlayAll: hasSongs ? () => playAll(context, songs) : null,
                onShuffle: hasSongs ? () => shuffleAll(context, songs) : null,
              ),
            ),
            if (hasSongs)
              SongSliverList(
                songs: songs,
                numbered: collection.isAlbum,
                subtitleFor: collection.rowSubtitle,
              )
            else
              SliverToBoxAdapter(
                child: EmptyState(
                  scrollable: false,
                  icon: Icons.music_off_outlined,
                  title: collection.emptyTitle,
                ),
              ),
            SliverToBoxAdapter(
              child:
                  SizedBox(height: 24 + MediaQuery.paddingOf(context).bottom),
            ),
          ],
        ),
      ),
    );
  }
}
