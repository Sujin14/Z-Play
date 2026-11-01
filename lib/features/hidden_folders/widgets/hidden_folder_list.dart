import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import 'hidden_folder_row.dart';

class HiddenFolderList extends StatelessWidget {
  const HiddenFolderList(
      {super.key, required this.folders, required this.onShow});

  final List<String> folders;
  final ValueChanged<String> onShow;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screen,
        0,
        AppSpacing.screen,
        24 + MediaQuery.paddingOf(context).bottom,
      ),
      sliver: SliverList.separated(
        itemCount: folders.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final folder = folders[index];
          return HiddenFolderRow(path: folder, onShow: () => onShow(folder));
        },
      ),
    );
  }
}
