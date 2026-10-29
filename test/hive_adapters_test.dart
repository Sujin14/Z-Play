import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:musicplayer/core/models/music_file_model.dart';
import 'package:musicplayer/core/models/playlist_model.dart';

void main() {
  late Directory dir;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('zplay_hive_');
    Hive.init(dir.path);
    if (!Hive.isAdapterRegistered(MusicFileAdapter().typeId)) {
      Hive.registerAdapter(MusicFileAdapter());
    }
    if (!Hive.isAdapterRegistered(PlaylistAdapter().typeId)) {
      Hive.registerAdapter(PlaylistAdapter());
    }
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await Hive.close();
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  // Existing installs have boxes written with these ids; changing them would
  // make stored playlists unreadable.
  test('adapter type ids are unchanged', () {
    expect(MusicFileAdapter().typeId, 0);
    expect(PlaylistAdapter().typeId, 1);
  });

  test('a playlist survives a write, close and reopen from disk', () async {
    var box = await Hive.openBox<Playlist>('playlistsBox');
    final key = await box.add(Playlist(
      name: 'Gym',
      songs: [
        MusicFile(path: '/music/a.mp3', title: 'A'),
        MusicFile(path: '/music/b.mp3', title: 'B'),
      ],
    ));
    await box.close();

    box = await Hive.openBox<Playlist>('playlistsBox');
    final stored = box.get(key)!;

    expect(stored.name, 'Gym');
    expect(stored.songs.map((song) => song.path),
        ['/music/a.mp3', '/music/b.mp3']);
    expect(stored.songs.map((song) => song.title), ['A', 'B']);
  });
}
