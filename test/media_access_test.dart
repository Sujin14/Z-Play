import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:musicplayer/core/data/library_repository.dart';
import 'package:musicplayer/core/data/library_store.dart';
import 'package:musicplayer/core/data/song_scanner.dart';
import 'package:musicplayer/core/models/media_access_model.dart';
import 'package:musicplayer/core/models/music_file_model.dart';
import 'package:musicplayer/core/models/playlist_model.dart';
import 'package:musicplayer/core/models/scan_result_model.dart';
import 'package:musicplayer/core/services/platform_capabilities.dart';
import 'package:musicplayer/core/state/library_view_model.dart';
import 'package:musicplayer/features/library/view_model/library_tabs_view_model.dart';

import 'support/fake_media_permission_service.dart';

// Records each scan and, like the real scanner, reports the missing access
// when nothing could be read.
class _RecordingScanner implements SongScanner {
  final scans = <MediaAccess>[];

  @override
  Future<ScanResult> scan({required MediaAccess access}) async {
    scans.add(access);
    return ScanResult(
      songs: const [],
      access: access,
      error: access == MediaAccess.granted
          ? null
          : 'Allow audio access to scan the music on this device.',
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late Directory dir;
  late LibraryStore store;
  late _RecordingScanner scanner;

  setUp(() async {
    dir = Directory.systemTemp.createTempSync('zplay_access_');
    Hive.init(dir.path);
    if (!Hive.isAdapterRegistered(MusicFileAdapter().typeId)) {
      Hive.registerAdapter(MusicFileAdapter());
    }
    if (!Hive.isAdapterRegistered(PlaylistAdapter().typeId)) {
      Hive.registerAdapter(PlaylistAdapter());
    }
    store = LibraryStore(
      favoritesBox: await Hive.openBox<String>('favorites'),
      playlistBox: await Hive.openBox<Playlist>('playlistsBox'),
      legacyRecentBox: await Hive.openBox('recentlyPlayedBox'),
      playCountBox: await Hive.openBox<int>('playCountsBox'),
      preferencesBox: await Hive.openBox('preferences'),
    );
    scanner = _RecordingScanner();
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await Hive.close();
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  LibraryViewModel libraryWith(FakeMediaPermissionService permissions) =>
      LibraryViewModel(LibraryRepository(
          store: store, scanner: scanner, permissions: permissions));

  LibraryTabsViewModel tabsFor(LibraryViewModel library) =>
      LibraryTabsViewModel(
        library,
        tabs: LibraryTabsViewModel.tabsFor(
            const PlatformCapabilities(supportsFolders: true)),
        selectedTab: 0,
      );

  test('granting access in the prompt goes straight on to the scan', () async {
    final prompt = Completer<MediaAccess>();
    final permissions = FakeMediaPermissionService(prompt: prompt);
    final library = libraryWith(permissions);

    final loading = library.load();
    await pumpEventQueue();
    expect(permissions.requests, 1);
    expect(scanner.scans, isEmpty, reason: 'waits for the answer');

    prompt.complete(MediaAccess.granted);
    await loading;

    expect(scanner.scans, [MediaAccess.granted]);
    expect(tabsFor(library).showsError, isFalse);
    expect(tabsFor(library).showsOpenSettings, isFalse);
  });

  test('denied access shows the allow-access state', () async {
    final library =
        libraryWith(FakeMediaPermissionService(answer: MediaAccess.denied));

    await library.load();

    final tabs = tabsFor(library);
    expect(tabs.showsError, isTrue);
    expect(tabs.error, contains('Allow audio access'));
    expect(tabs.showsOpenSettings, isTrue);
  });

  test('permanently denied access offers Open settings', () async {
    final permissions =
        FakeMediaPermissionService(answer: MediaAccess.permanentlyDenied);
    final library = libraryWith(permissions);

    await library.load();
    final tabs = tabsFor(library);
    expect(tabs.showsOpenSettings, isTrue);

    tabs.openSettings();
    await pumpEventQueue();
    expect(permissions.settingsOpened, 1);
  });
}
