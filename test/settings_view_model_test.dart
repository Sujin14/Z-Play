import 'package:flutter_test/flutter_test.dart';
import 'package:musicplayer/core/data/library_repository.dart';
import 'package:musicplayer/core/services/app_info_service.dart';
import 'package:musicplayer/core/services/platform_capabilities.dart';
import 'package:musicplayer/core/state/library_view_model.dart';
import 'package:musicplayer/features/settings/view_model/settings_view_model.dart';

// The settings view model only reads the library's settings, which need no
// repository calls.
class _UnusedRepository implements LibraryRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  SettingsViewModel settingsFor({required bool supportsFolders}) =>
      SettingsViewModel(
        LibraryViewModel(_UnusedRepository()),
        const AppInfoService(version: '1.0.0'),
        PlatformCapabilities(supportsFolders: supportsFolders),
      );

  test('Rescan storage keeps the Android wording where folders exist', () {
    expect(settingsFor(supportsFolders: true).rescanSubtitle,
        'Read every mounted volume and the system music index again.');
  });

  test('Rescan storage says "Refresh your music library" on iOS', () {
    expect(settingsFor(supportsFolders: false).rescanSubtitle,
        'Refresh your music library');
  });
}
