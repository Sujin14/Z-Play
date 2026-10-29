import 'package:flutter/material.dart';

import '../../../core/models/collection_kind_model.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/layout_utils.dart';
import '../view_model/library_tabs_view_model.dart';
import 'artist_card.dart';
import 'tab_empty_state.dart';

class ArtistsTab extends StatelessWidget {
  const ArtistsTab({super.key, required this.tabs});

  final LibraryTabsViewModel tabs;

  static const _columns = 3;
  static const double _spacing = 14;
  static const double _rowSpacing = 18;

  @override
  Widget build(BuildContext context) {
    final groups = tabs.artists;
    if (groups.isEmpty) {
      return TabEmptyState.nothingYet(Icons.person_off_outlined);
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth =
            (constraints.maxWidth - AppSpacing.screen * 2 - _spacing * 2) /
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
            return ArtistCard(
              name: group.title,
              subtitle: group.subtitle,
              avatarSize: itemWidth,
              onTap: () => tabs.openGroup(CollectionKind.artist, group),
            );
          },
        );
      },
    );
  }
}
