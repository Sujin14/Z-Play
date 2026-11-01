import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/platform_capabilities.dart';
import '../../../core/state/library_view_model.dart';
import '../model/library_tab_model.dart';
import '../view_model/library_tabs_view_model.dart';
import '../widgets/albums_tab.dart';
import '../widgets/artists_tab.dart';
import '../widgets/folders_tab.dart';
import '../widgets/library_count_row.dart';
import '../widgets/library_header.dart';
import '../widgets/library_search_field.dart';
import '../widgets/library_tab_chips.dart';
import '../widgets/songs_tab.dart';
import '../widgets/sort_sheet.dart';

class LibraryView extends StatefulWidget {
  const LibraryView({super.key});

  @override
  State<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<LibraryView>
    with SingleTickerProviderStateMixin {
  late final List<LibraryTab> _tabs;
  late final TabController _tabController;
  final TextEditingController _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabs = LibraryTabsViewModel.tabsFor(context.read<PlatformCapabilities>());
    // Rebuilds on swipe too, so the chips and count follow the visible tab.
    _tabController = TabController(length: _tabs.length, vsync: this)
      ..addListener(() {
        if (mounted) setState(() {});
      });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryViewModel>();
    final tabs = LibraryTabsViewModel(library,
        tabs: _tabs, selectedTab: _tabController.index);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const LibraryHeader(),
            LibrarySearchField(
              controller: _search,
              hasQuery: tabs.isSearching,
              onChanged: library.setQuery,
              onClear: () {
                _search.clear();
                library.setQuery('');
              },
            ),
            const SizedBox(height: 16),
            LibraryTabChips(
              tabs: tabs.labels,
              selected: _tabController.index,
              onSelected: _tabController.animateTo,
            ),
            LibraryCountRow(
              count: tabs.countLabel,
              sortLabel: tabs.showsSort ? tabs.sortLabel : null,
              onSort: () => showSortSheet(context, library),
            ),
            Expanded(
              child: tabs.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        for (final tab in _tabs)
                          switch (tab) {
                            LibraryTab.songs => SongsTab(tabs: tabs),
                            LibraryTab.folders => FoldersTab(tabs: tabs),
                            LibraryTab.albums => AlbumsTab(tabs: tabs),
                            LibraryTab.artists => ArtistsTab(tabs: tabs),
                          },
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
