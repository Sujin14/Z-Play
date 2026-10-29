import 'package:flutter/material.dart';

import '../../../core/models/collection_kind_model.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/layout_utils.dart';
import '../view_model/library_tabs_view_model.dart';
import 'album_card.dart';
import 'tab_empty_state.dart';

class AlbumsTab extends StatelessWidget {
  const AlbumsTab({super.key, required this.tabs});

  final LibraryTabsViewModel tabs;

  static const _columns = 2;
  static const double _spacing = 16;
  static const double _rowSpacing = 20;

  @override
  Widget build(BuildContext context) {
    final groups = tabs.albums;
    if (groups.isEmpty) return TabEmptyState.nothingYet(Icons.album_outlined);
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth =
            (constraints.maxWidth - AppSpacing.screen * 2 - _spacing) /
                _columns;
        return GridView.builder(
          padding: tabListPadding(context, AppSpacing.screen),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _columns,
            crossAxisSpacing: _spacing,
            mainAxisSpacing: _rowSpacing,
            mainAxisExtent: coverGridCellExtent(context, itemWidth),
          ),
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final group = groups[index];
            return AlbumCard(
              title: group.title,
              subtitle: tabs.albumSubtitle(group),
              coverSize: itemWidth,
              onTap: () => tabs.openGroup(CollectionKind.album, group),
            );
          },
        );
      },
    );
  }
}
