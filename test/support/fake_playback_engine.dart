import 'dart:async';

import 'package:musicplayer/core/models/playback_error_model.dart';
import 'package:musicplayer/core/models/playback_track_model.dart';
import 'package:musicplayer/core/models/repeat_mode_model.dart';
import 'package:musicplayer/core/models/track_change_model.dart';
import 'package:musicplayer/core/services/playback_engine.dart';

// Keeps its own list like a real engine and records every call as a short
// string ("setQueue:1@0", "seek:5000", "insert:3", ...). Tests drive the
// platform's side with advanceTo, finishQueue and failAt.
class FakePlaybackEngine implements PlaybackEngine {
  final calls = <String>[];
  final failingPaths = <String>{};
  List<PlaybackTrack> tracks = [];
  int index = 0;

  // While set, seekToIndex waits for it, so a test can start another song
  // in the middle of a start.
  Completer<void>? holdSeeks;

  final _playing = StreamController<bool>.broadcast();
  final _position = StreamController<Duration>.broadcast();
  final _duration = StreamController<Duration>.broadcast();
  final _trackChanges = StreamController<TrackChange>.broadcast();
  final _completed = StreamController<void>.broadcast();
  final _errors = StreamController<PlaybackError>.broadcast();

  List<String> get paths => [for (final track in tracks) track.path];
  String? get currentPath => tracks.isEmpty ? null : tracks[index].path;

  void emitPosition(Duration value) => _position.add(value);
  void emitDuration(Duration value) => _duration.add(value);
  void emitPlaying(bool value) => _playing.add(value);

  // The platform finished a song and moved to index by itself.
  void advanceTo(int next) {
    index = next;
    _trackChanges.add(TrackChange(index: next, automatic: true));
  }

  void finishQueue() => _completed.add(null);

  void failAt(int at) =>
      _errors.add(PlaybackError(index: at, message: 'broken file'));

  bool get _currentFails => failingPaths.contains(currentPath);

  @override
  Future<void> configure() async => calls.add('configure');

  @override
  Future<bool> setQueue(List<PlaybackTrack> tracks,
      {required int index, Duration position = Duration.zero}) async {
    calls.add('setQueue:$index@${position.inMilliseconds}');
    this.tracks = List.of(tracks);
    this.index = index;
    return !_currentFails;
  }

  @override
  Future<void> play() async => calls.add('play');

  @override
  Future<void> pause() async => calls.add('pause');

  @override
  Future<void> stop() async {
    calls.add('stop');
    tracks = [];
    index = 0;
  }

  @override
  Future<void> seek(Duration position) async =>
      calls.add('seek:${position.inMilliseconds}');

  @override
  Future<bool> seekToIndex(int index,
      {Duration position = Duration.zero}) async {
    calls.add('seekToIndex:$index');
    await holdSeeks?.future;
    this.index = index;
    return !_currentFails;
  }

  @override
  Future<void> setSpeed(double speed) async => calls.add('speed:$speed');

  @override
  Future<void> setRepeat(RepeatMode mode) async =>
      calls.add('repeat:${mode.name}');

  @override
  Future<void> insertTrack(int at, PlaybackTrack track) async {
    calls.add('insert:$at');
    tracks.insert(at, track);
    if (at <= index) index++;
  }

  @override
  Future<void> removeTrack(int at) async {
    calls.add('remove:$at');
    tracks.removeAt(at);
    if (at < index) index--;
  }

  @override
  Future<void> moveTrack(int from, int to) async {
    calls.add('move:$from:$to');
    final track = tracks.removeAt(from);
    tracks.insert(to, track);
    if (index == from) {
      index = to;
    } else if (from < index && to >= index) {
      index--;
    } else if (from > index && to <= index) {
      index++;
    }
  }

  @override
  Future<void> replaceAround({
    required List<PlaybackTrack> before,
    required List<PlaybackTrack> after,
  }) async {
    calls.add('replaceAround');
    final current = tracks[index];
    tracks = [...before, current, ...after];
    index = before.length;
  }

  @override
  Stream<bool> get playingChanges => _playing.stream;

  @override
  Stream<Duration> get positionChanges => _position.stream;

  @override
  Stream<Duration> get durationChanges => _duration.stream;

  @override
  Stream<TrackChange> get trackChanges => _trackChanges.stream;

  @override
  Stream<void> get queueCompleted => _completed.stream;

  @override
  Stream<PlaybackError> get errors => _errors.stream;

  @override
  Future<void> dispose() async {
    calls.add('dispose');
    await _playing.close();
    await _position.close();
    await _duration.close();
    await _trackChanges.close();
    await _completed.close();
    await _errors.close();
  }
}
