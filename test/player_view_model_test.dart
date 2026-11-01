import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:musicplayer/core/data/library_repository.dart';
import 'package:musicplayer/core/models/playback_snapshot_model.dart';
import 'package:musicplayer/core/models/repeat_mode_model.dart';
import 'package:musicplayer/core/models/song_model.dart';
import 'package:musicplayer/core/state/player_view_model.dart';

import 'support/fake_playback_engine.dart';

// Keeps the saved queue and play counts in memory; these are the only
// repository calls the player makes.
class _MemoryRepository implements LibraryRepository {
  _MemoryRepository({required this.known});

  PlaybackSnapshot saved = PlaybackSnapshot.empty;
  final List<Song> known;
  final plays = <String>[];

  @override
  PlaybackSnapshot playback() => saved;

  @override
  Future<void> savePlayback(PlaybackSnapshot snapshot) async =>
      saved = snapshot;

  @override
  Future<void> clearPlayback() async => saved = PlaybackSnapshot.empty;

  @override
  Future<void> recordPlay(Song song) async => plays.add(song.path);

  @override
  Song? songByPath(String path) {
    for (final song in known) {
      if (song.path == path) return song;
    }
    return null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _a = Song(path: '/music/a.mp3', title: 'Song A');
const _b = Song(path: '/music/b.mp3', title: 'Song B');
const _c = Song(path: '/music/c.mp3', title: 'Song C');
const _d = Song(path: '/music/d.mp3', title: 'Song D');
const _songs = [_a, _b, _c];
const _length = Duration(minutes: 3);

void main() {
  late FakePlaybackEngine engine;
  late _MemoryRepository repository;
  late PlayerViewModel player;

  setUp(() {
    engine = FakePlaybackEngine();
    repository = _MemoryRepository(known: _songs);
    player = PlayerViewModel(
      repository: repository,
      onPlayed: () async {},
      engine: engine,
    );
  });

  tearDown(() => player.dispose());

  Future<void> startAt(int index) async {
    await player.play(_songs[index], queue: _songs, index: index);
    engine.calls.clear();
  }

  List<String> pathsOf(List<Song> songs) => [for (final s in songs) s.path];

  group('starting', () {
    test('playing a song loads the whole queue, starts it and counts it',
        () async {
      await player.play(_b, queue: _songs, index: 1);

      expect(engine.calls, ['setQueue:1@0', 'play']);
      expect(engine.paths, pathsOf(_songs));
      expect(engine.currentPath, _b.path);
      expect(player.current, _b);
      expect(player.isPlaying, isTrue);
      expect(repository.plays, [_b.path]);
    });

    test('iOS library songs go to the engine as URLs', () async {
      const ios = Song(path: 'ipod-library://item/item.mp3?id=1', title: 'i');
      await player.play(ios, queue: const [ios, _a], index: 0);

      expect([for (final t in engine.tracks) t.isUrl], [true, false]);
    });

    test('Next moves within the loaded list instead of reloading it', () async {
      await startAt(0);
      await player.next();

      expect(engine.calls, ['seekToIndex:1', 'play']);
      expect(repository.plays, [_a.path, _b.path]);
    });

    test('a start overtaken by a newer one never plays', () async {
      await startAt(0);
      engine.holdSeeks = Completer<void>();

      final toB = player.next();
      final toC = player.next();
      engine.holdSeeks!.complete();
      await Future.wait([toB, toC]);

      expect(engine.calls, ['seekToIndex:1', 'seekToIndex:2', 'play']);
      expect(player.current, _c);
      expect(repository.plays, [_a.path, _c.path]);
    });

    test('speed is a player setting the engine keeps across songs', () async {
      await startAt(0);
      await player.setSpeed(1.5);
      await player.next();

      expect(engine.calls, ['speed:1.5', 'seekToIndex:1', 'play']);
    });
  });

  group('position', () {
    test('positions from the engine are published', () async {
      await startAt(0);
      engine.emitPosition(const Duration(seconds: 7));
      await pumpEventQueue();

      expect(player.position.value, const Duration(seconds: 7));
    });

    test('the position is saved every 5 seconds, again on every new song',
        () async {
      await startAt(0);
      engine.emitPosition(const Duration(seconds: 4));
      await pumpEventQueue();
      expect(repository.saved.positionMs, 0);

      engine.emitPosition(const Duration(seconds: 5));
      await pumpEventQueue();
      expect(repository.saved.positionMs, 5000);

      engine.advanceTo(1);
      await pumpEventQueue();
      engine.emitPosition(const Duration(seconds: 5));
      await pumpEventQueue();
      expect(repository.saved.index, 1);
      expect(repository.saved.positionMs, 5000);
    });
  });

  group('the platform moving on', () {
    test('records the new song once and updates Now Playing', () async {
      await startAt(0);
      var notified = 0;
      player.addListener(() => notified++);

      engine.advanceTo(1);
      await pumpEventQueue();

      expect(player.current, _b);
      expect(player.position.value, Duration.zero);
      expect(repository.plays, [_a.path, _b.path]);
      expect(notified, greaterThan(0));
      expect(engine.calls, isEmpty, reason: 'no Dart restart');
    });

    test('repeat one replays the same song without counting it', () async {
      await startAt(0);
      player
        ..cycleRepeat()
        ..cycleRepeat();
      expect(player.repeatMode, RepeatMode.one);
      expect(engine.calls, ['repeat:all', 'repeat:one']);

      engine.advanceTo(0);
      await pumpEventQueue();

      expect(player.current, _a);
      expect(repository.plays, [_a.path]);
    });

    test('repeat all wraps from the last song to the first', () async {
      await startAt(2);
      player.cycleRepeat();

      engine.advanceTo(0);
      await pumpEventQueue();

      expect(player.current, _a);
      expect(repository.plays, [_c.path, _a.path]);
    });

    test('the end of the queue stops cleanly', () async {
      await startAt(2);
      engine.emitPosition(const Duration(seconds: 30));
      await pumpEventQueue();

      engine.finishQueue();
      await pumpEventQueue();

      expect(engine.calls, ['pause']);
      expect(player.isPlaying, isFalse);
      expect(player.position.value, Duration.zero);
      expect(player.current, _c);
    });

    test('play after the end restarts the last song from 0', () async {
      await startAt(2);
      engine.finishQueue();
      await pumpEventQueue();
      engine.calls.clear();

      await player.toggle();

      expect(engine.calls, ['seek:0', 'play']);
      expect(player.isPlaying, isTrue);
      expect(repository.plays, [_c.path], reason: 'restart is not counted');
    });
  });

  group('queue edits keep the current song playing', () {
    test('adding a song inserts it at the end of the engine list', () async {
      await startAt(0);
      player.addToQueue(_d);

      expect(engine.calls, ['insert:3']);
      expect(engine.paths, pathsOf(player.upNext));
      expect(engine.currentPath, _a.path);
    });

    test('removing another song removes it from the engine list', () async {
      await startAt(0);
      player.removeFromQueue(2);

      expect(engine.calls, ['remove:2']);
      expect(engine.paths, pathsOf(player.upNext));
      expect(engine.currentPath, _a.path);
    });

    test('reordering moves the song in the engine list', () async {
      await startAt(0);
      player.reorderQueue(2, 0);

      expect(engine.calls, ['move:2:0']);
      expect(engine.paths, pathsOf(player.upNext));
      expect(engine.currentPath, _a.path);
    });

    test('play next rebuilds the list around the current song', () async {
      await startAt(0);
      player.playNext(_c);

      expect(engine.calls, ['replaceAround']);
      expect(engine.paths, pathsOf(player.upNext));
      expect(engine.currentPath, _a.path);
    });

    test('removing the current song starts the next one', () async {
      await startAt(0);
      player.removeFromQueue(0);
      await pumpEventQueue();

      expect(player.current, _b);
      expect(engine.calls, ['setQueue:0@0', 'play']);
      expect(engine.paths, pathsOf(player.upNext));
    });

    test('shuffle reorders around the current song', () async {
      await startAt(1);
      player.toggleShuffle();

      expect(engine.calls, ['replaceAround']);
      expect(engine.currentPath, _b.path);
      expect(engine.paths, pathsOf(player.upNext));

      engine.calls.clear();
      player.toggleShuffle();
      expect(engine.calls, ['replaceAround']);
      expect(engine.paths, pathsOf(_songs));
      expect(engine.currentPath, _b.path);
    });
  });

  group('sleep', () {
    test('"end of track" trims the list, then pauses at the end and restores',
        () async {
      await startAt(0);
      player.sleepAfterCurrentTrack();

      expect(engine.calls, ['replaceAround', 'repeat:off']);
      expect(engine.paths, [_a.path]);

      engine.calls.clear();
      engine.finishQueue();
      await pumpEventQueue();

      expect(engine.calls, ['pause', 'replaceAround', 'repeat:off', 'seek:0']);
      expect(engine.paths, pathsOf(_songs));
      expect(player.current, _a);
      expect(player.stopAfterCurrent, isFalse);
      expect(player.isPlaying, isFalse);
    });

    test('cancelling "end of track" restores the list and repeat', () async {
      await startAt(0);
      player
        ..cycleRepeat()
        ..sleepAfterCurrentTrack();
      engine.calls.clear();

      player.cancelSleep();

      expect(engine.calls, ['replaceAround', 'repeat:all']);
      expect(engine.paths, pathsOf(_songs));
    });

    testWidgets('the minute timer pauses when it runs out', (tester) async {
      await startAt(0);
      player.startSleepTimer(const Duration(minutes: 15));

      await tester.pump(const Duration(minutes: 14, seconds: 59));
      expect(engine.calls, isNot(contains('pause')));

      await tester.pump(const Duration(seconds: 1));
      expect(engine.calls, contains('pause'));
      expect(player.sleepUntil, isNull);
    });
  });

  group('errors', () {
    test('a song that fails to start is reported and skipped', () async {
      engine.failingPaths.add(_b.path);

      final started = await player.play(_b, queue: _songs, index: 1);

      expect(started, isTrue);
      expect(player.current, _c);
      expect(player.error, 'Cannot play Song B.');
      expect(player.isPlaying, isTrue);
      expect(repository.plays, [_c.path]);
    });

    test('a song that fails while playing is reported and skipped', () async {
      await startAt(0);

      engine.failAt(0);
      await pumpEventQueue();

      expect(player.current, _b);
      expect(player.error, 'Cannot play Song A.');
      expect(repository.plays, [_a.path, _b.path]);
    });

    test('a full pass of failures stops instead of looping', () async {
      engine.failingPaths.addAll(pathsOf(_songs));
      player.cycleRepeat(); // repeat all would otherwise loop forever

      final started = await player.play(_a, queue: _songs, index: 0);

      expect(started, isFalse);
      expect(player.isPlaying, isFalse);
      expect(engine.calls.where((call) => call.startsWith('setQueue')),
          hasLength(3));
      expect(engine.calls.last, 'pause');
      expect(repository.plays, isEmpty);
    });
  });

  group('restore', () {
    test('loads the saved queue without playing; play then continues',
        () async {
      repository.saved = PlaybackSnapshot(
        paths: pathsOf(_songs),
        index: 1,
        positionMs: 42000,
        speed: 1.25,
      );

      await player.prepare();

      expect(engine.calls, ['configure', 'speed:1.25', 'setQueue:1@42000']);
      expect(player.current, _b);
      expect(player.position.value, const Duration(seconds: 42));
      expect(player.isPlaying, isFalse);

      engine.calls.clear();
      await player.toggle();
      expect(engine.calls, ['play']);
      expect(repository.plays, isEmpty, reason: 'resuming is not a new play');
    });
  });

  group('seekBy', () {
    Future<void> at(Duration position) async {
      engine.emitDuration(_length);
      engine.emitPosition(position);
      await pumpEventQueue();
      engine.calls.clear();
    }

    final nearEnd = _length - PlayerViewModel.seekEndMargin;

    test('rewind stops at 0 and updates the position', () async {
      await startAt(0);
      await at(const Duration(seconds: 4));

      await player.seekBy(const Duration(seconds: -10));

      expect(engine.calls, ['seek:0']);
      expect(player.position.value, Duration.zero);
    });

    test('rewind moves back 10 seconds', () async {
      await startAt(0);
      await at(const Duration(seconds: 40));

      await player.seekBy(const Duration(seconds: -10));

      expect(engine.calls, ['seek:30000']);
      expect(player.position.value, const Duration(seconds: 30));
    });

    test('forward stops just short of the end', () async {
      await startAt(0);
      await at(const Duration(minutes: 2, seconds: 55));

      await player.seekBy(const Duration(seconds: 10));

      expect(engine.calls, ['seek:${nearEnd.inMilliseconds}']);
      expect(player.position.value, nearEnd);
    });

    test('forward is ignored while the length is unknown', () async {
      await startAt(0);
      engine.emitPosition(const Duration(seconds: 20));
      await pumpEventQueue();
      engine.calls.clear();

      await player.seekBy(const Duration(seconds: 10));

      expect(engine.calls, isEmpty);
    });

    test('forward at the end lets the song finish and moves on', () async {
      await startAt(0);
      await at(const Duration(minutes: 2, seconds: 58));

      await player.seekBy(const Duration(seconds: 10));
      engine.advanceTo(1);
      await pumpEventQueue();

      expect(player.current, _b);
      expect(repository.plays, [_a.path, _b.path]);
    });

    test('forward at the end with repeat one replays the song', () async {
      await startAt(0);
      player
        ..cycleRepeat()
        ..cycleRepeat();
      await at(const Duration(minutes: 2, seconds: 58));

      await player.seekBy(const Duration(seconds: 10));
      engine.advanceTo(0);
      await pumpEventQueue();

      expect(player.current, _a);
      expect(repository.plays, [_a.path]);
    });

    test('forward at the end with "end of track" sleep pauses', () async {
      await startAt(0);
      player.sleepAfterCurrentTrack();
      await at(const Duration(minutes: 2, seconds: 58));

      await player.seekBy(const Duration(seconds: 10));
      engine.finishQueue();
      await pumpEventQueue();

      expect(engine.calls, contains('pause'));
      expect(player.isPlaying, isFalse);
      expect(player.current, _a);
      expect(player.position.value, Duration.zero);
    });
  });
}
