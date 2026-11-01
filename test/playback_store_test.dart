import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:musicplayer/core/data/library_store.dart';
import 'package:musicplayer/core/models/music_file_model.dart';
import 'package:musicplayer/core/models/playback_snapshot_model.dart';
import 'package:musicplayer/core/models/playlist_model.dart';
import 'package:musicplayer/core/models/repeat_mode_model.dart';

void main() {
  late Directory dir;
  late Box<dynamic> preferences;
  late LibraryStore store;

  setUp(() async {
    dir = Directory.systemTemp.createTempSync('zplay_playback_');
    Hive.init(dir.path);
    if (!Hive.isAdapterRegistered(MusicFileAdapter().typeId)) {
      Hive.registerAdapter(MusicFileAdapter());
    }
    if (!Hive.isAdapterRegistered(PlaylistAdapter().typeId)) {
      Hive.registerAdapter(PlaylistAdapter());
    }
    preferences = await Hive.openBox('preferences');
    store = LibraryStore(
      favoritesBox: await Hive.openBox<String>('favorites'),
      playlistBox: await Hive.openBox<Playlist>('playlistsBox'),
      legacyRecentBox: await Hive.openBox('recentlyPlayedBox'),
      playCountBox: await Hive.openBox<int>('playCountsBox'),
      preferencesBox: preferences,
    );
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await Hive.close();
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  test('a save from before repeat and shuffle loads with both off', () async {
    await preferences.putAll({
      'queue': ['/a.mp3', '/b.mp3'],
      'queueIndex': 1,
      'positionMs': 9000,
      'speed': 1.5,
    });

    final snapshot = store.playback();

    expect(snapshot.paths, ['/a.mp3', '/b.mp3']);
    expect(snapshot.index, 1);
    expect(snapshot.positionMs, 9000);
    expect(snapshot.speed, 1.5);
    expect(snapshot.originalPaths, isEmpty);
    expect(snapshot.shuffling, isFalse);
    expect(snapshot.repeat, RepeatMode.off);
  });

  test('every field survives a write and a reopen from disk', () async {
    await store.savePlayback(const PlaybackSnapshot(
      paths: ['/c.mp3', '/a.mp3', '/b.mp3'],
      index: 1,
      positionMs: 30000,
      speed: 1.25,
      originalPaths: ['/a.mp3', '/b.mp3', '/c.mp3'],
      shuffling: true,
      repeat: RepeatMode.one,
    ));
    await preferences.close();
    final reopened = LibraryStore(
      favoritesBox: Hive.box<String>('favorites'),
      playlistBox: Hive.box<Playlist>('playlistsBox'),
      legacyRecentBox: Hive.box('recentlyPlayedBox'),
      playCountBox: Hive.box<int>('playCountsBox'),
      preferencesBox: await Hive.openBox('preferences'),
    );

    final snapshot = reopened.playback();

    expect(snapshot.paths, ['/c.mp3', '/a.mp3', '/b.mp3']);
    expect(snapshot.index, 1);
    expect(snapshot.positionMs, 30000);
    expect(snapshot.speed, 1.25);
    expect(snapshot.originalPaths, ['/a.mp3', '/b.mp3', '/c.mp3']);
    expect(snapshot.shuffling, isTrue);
    expect(snapshot.repeat, RepeatMode.one);
  });

  test('an unknown repeat value falls back to off', () async {
    await preferences.put('repeat', 'sideways');

    expect(store.playback().repeat, RepeatMode.off);
  });
}
