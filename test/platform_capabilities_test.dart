import 'package:flutter_test/flutter_test.dart';
import 'package:musicplayer/core/services/platform_capabilities.dart';
import 'package:musicplayer/features/library/model/library_tab_model.dart';
import 'package:musicplayer/features/library/view_model/library_tabs_view_model.dart';

void main() {
  test('the Library has a Folders tab only where folders exist', () {
    expect(
      LibraryTabsViewModel.tabsFor(
          const PlatformCapabilities(supportsFolders: true)),
      LibraryTab.values,
    );
    expect(
      LibraryTabsViewModel.tabsFor(
          const PlatformCapabilities(supportsFolders: false)),
      [LibraryTab.songs, LibraryTab.albums, LibraryTab.artists],
    );
  });
}
