import 'package:flutter/material.dart';

import '../../../core/models/collection_kind_model.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/layout_utils.dart';
import '../view_model/library_tabs_view_model.dart';
import 'folder_row.dart';
import 'tab_empty_state.dart';

class FoldersTab extends StatelessWidget {
  const FoldersTab({super.key, required this.tabs});

  final LibraryTabsViewModel tabs;

  @override
  Widget build(BuildContext context) {
    final groups = tabs.folders;
    if (groups.isEmpty) {
      return TabEmptyState.nothingYet(Icons.folder_off_outlined);
    }
    return ListView.separated(
      padding: tabListPadding(context, AppSpacing.screen),
      itemCount: groups.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final group = groups[index];
        return FolderRow(
          title: group.title,
          subtitle: tabs.folderSubtitle(group),
          onTap: () => tabs.openGroup(CollectionKind.folder, group),
          // Hidden by full path, never the shortened display path.
          onHide: () => tabs.library.hideFolder(group.id),
        );
      },
    );
  }
}
