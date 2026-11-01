import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:musicplayer/core/data/library_repository.dart';
import 'package:musicplayer/core/data/library_store.dart';
import 'package:musicplayer/core/data/song_scanner.dart';
import 'package:musicplayer/core/models/media_access_model.dart';
import 'package:musicplayer/core/models/music_file_model.dart';
import 'package:musicplayer/core/models/playlist_model.dart';
import 'package:musicplayer/core/models/scan_result_model.dart';
import 'package:musicplayer/core/navigation/navigation_service.dart';
import 'package:musicplayer/core/state/library_view_model.dart';
import 'package:musicplayer/core/state/player_view_model.dart';
import 'package:musicplayer/core/state/playlist_view_model.dart';
import 'package:musicplayer/core/theme/app_tokens.dart';
import 'package:musicplayer/features/splash/view/splash_view.dart';
import 'package:provider/provider.dart';

import 'support/fake_media_permission_service.dart';

// Stands in for the device scan, which needs platform channels.
class _FakeScanner implements SongScanner {
  @override
  Future<ScanResult> scan({required MediaAccess access}) async =>
      ScanResult(songs: const [], access: access);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _StubPlaylists implements PlaylistViewModel {
  @override
  void load() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// The real player needs the audio plugin; the splash only awaits prepare().
class _StubPlayer implements PlayerViewModel {
  @override
  Future<void> prepare() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late Directory dir;
  late LibraryViewModel library;

  setUp(() async {
    dir = Directory.systemTemp.createTempSync('zplay_splash_');
    Hive.init(dir.path);
    if (!Hive.isAdapterRegistered(MusicFileAdapter().typeId)) {
      Hive.registerAdapter(MusicFileAdapter());
    }
    if (!Hive.isAdapterRegistered(PlaylistAdapter().typeId)) {
      Hive.registerAdapter(PlaylistAdapter());
    }
    final store = LibraryStore(
      favoritesBox: await Hive.openBox<String>('favorites'),
      playlistBox: await Hive.openBox<Playlist>('playlistsBox'),
      legacyRecentBox: await Hive.openBox('recentlyPlayedBox'),
      playCountBox: await Hive.openBox<int>('playCountsBox'),
      preferencesBox: await Hive.openBox('preferences'),
    );
    library = LibraryViewModel(LibraryRepository(
        store: store,
        scanner: _FakeScanner(),
        permissions: FakeMediaPermissionService()));
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await Hive.close();
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  testWidgets('a cold start loads the library without a build-phase error',
      (tester) async {
    Provider.debugCheckInvalidValueType = null;
    // Mounting the splash from scratch is what a hot restart does.
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<LibraryViewModel>.value(value: library),
        Provider<PlaylistViewModel>.value(value: _StubPlaylists()),
        Provider<PlayerViewModel>.value(value: _StubPlayer()),
      ],
      child: MaterialApp(
        navigatorKey: NavigationService.navigatorKey,
        theme: ThemeData(extensions: const [AppTokens.dark]),
        home: const SplashView(),
        onGenerateRoute: (settings) =>
            MaterialPageRoute(builder: (_) => const Text('shell')),
      ),
    ));
    expect(tester.takeException(), isNull);

    // Pumps until the splash hands over; the 6s cap bounds the wait even if
    // the Lottie never loads under the test clock.
    for (var i = 0; i < 80 && find.text('shell').evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    }
    await tester.pumpAndSettle();

    expect(find.text('shell'), findsOneWidget);
    expect(library.loading, isFalse);
    expect(tester.takeException(), isNull);
  });
}
