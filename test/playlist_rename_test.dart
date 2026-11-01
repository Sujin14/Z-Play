import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:musicplayer/core/data/library_store.dart';
import 'package:musicplayer/core/data/song_scanner.dart';
import 'package:musicplayer/core/models/music_file_model.dart';
import 'package:musicplayer/core/models/playlist_model.dart';
import 'package:musicplayer/core/models/song_model.dart';
import 'package:musicplayer/core/data/library_repository.dart';
import 'package:musicplayer/core/data/playlist_repository.dart';
import 'package:musicplayer/core/state/library_view_model.dart';
import 'package:musicplayer/core/state/playlist_view_model.dart';

import 'support/fake_media_permission_service.dart';

void main() {
  late Directory dir;
  late PlaylistViewModel playlists;

  setUp(() async {
    dir = Directory.systemTemp.createTempSync('zplay_playlists_');
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
    final library = LibraryViewModel(LibraryRepository(
        store: store,
        scanner: SongScanner(),
        permissions: FakeMediaPermissionService()));
    playlists = PlaylistViewModel(
        repository: PlaylistRepository(store), library: library);
    await playlists.create('Gym', const []);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await Hive.close();
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  test('a renamed playlist is still found by its id', () async {
    final id = playlists.named('Gym')!.id!;

    final error = await playlists
        .update(originalName: 'Gym', name: 'Run', songs: const []);

    expect(error, isNull);
    expect(playlists.byId(id)?.name, 'Run');
    expect(playlists.named('Gym'), isNull);
  });

  test('changing the songs keeps the same id', () async {
    final id = playlists.named('Gym')!.id!;
    const song = Song(path: '/music/a.mp3', title: 'A');

    await playlists
        .update(originalName: 'Gym', name: 'Gym', songs: const [song]);

    expect(playlists.byId(id)?.songs.map((s) => s.path), ['/music/a.mp3']);
  });

  test('renaming to a taken name fails and leaves the playlist alone',
      () async {
    await playlists.create('Focus', const []);
    final id = playlists.named('Gym')!.id!;

    final error = await playlists
        .update(originalName: 'Gym', name: 'Focus', songs: const []);

    expect(error, 'A playlist with this name already exists');
    expect(playlists.byId(id)?.name, 'Gym');
  });
}
