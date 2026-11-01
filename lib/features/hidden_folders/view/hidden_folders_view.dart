import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/state/library_view_model.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/gradient_scaffold.dart';
import '../view_model/hidden_folders_view_model.dart';
import '../widgets/hidden_folder_list.dart';
import '../widgets/hidden_folders_header.dart';

class HiddenFoldersView extends StatelessWidget {
  const HiddenFoldersView({super.key});

  @override
  Widget build(BuildContext context) {
    final hidden = HiddenFoldersViewModel(context.watch<LibraryViewModel>());
    return GradientScaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: HiddenFoldersHeader()),
            if (hidden.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.paddingOf(context).bottom),
                  child: const EmptyState(
                    scrollable: false,
                    icon: Icons.folder_off_outlined,
                    title: 'No hidden folders',
                    message:
                        'Hide a folder from the Folders tab and it will show up here.',
                  ),
                ),
              )
            else
              HiddenFolderList(folders: hidden.folders, onShow: hidden.show),
          ],
        ),
      ),
    );
  }
}
