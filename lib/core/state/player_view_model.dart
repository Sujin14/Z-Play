import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/playback_error_model.dart';
import '../models/playback_track_model.dart';
import '../models/song_model.dart';
import '../data/library_repository.dart';
import '../models/track_change_model.dart';
import '../services/playback_controls.dart';
import '../services/playback_engine.dart';
import 'playback_queue.dart';
import '../models/playback_snapshot_model.dart';
import '../models/repeat_mode_model.dart';

// PlaybackQueue decides the order; the engine holds a mirror of it and moves
// to the next track by itself. Every queue change is applied to the queue
// first and then copied to the engine without restarting the current song.
class PlayerViewModel extends ChangeNotifier implements PlaybackControls {
  PlayerViewModel({
    required LibraryRepository repository,
    required Future<void> Function() onPlayed,
    required PlaybackEngine engine,
  })  : _repository = repository,
        _onPlayed = onPlayed,
        _engine = engine {
    _bindEngine();
  }

  final LibraryRepository _repository;
  final Future<void> Function() _onPlayed;
  final PlaybackEngine _engine;
  @override
  final ValueNotifier<Duration> position = ValueNotifier(Duration.zero);

  PlaybackQueue _queue = PlaybackQueue(songs: const []);
  RepeatMode repeatMode = RepeatMode.off;
  @override
  bool isPlaying = false;
  bool stopAfterCurrent = false;
  @override
  Duration duration = Duration.zero;
  @override
  double speed = 1;
  String? error;
  DateTime? sleepUntil;
  Duration _sleepDuration = Duration.zero;
  // The engine holds the queue and can move within it; false before the
  // first load and after stop() or a failed track.
  bool _loaded = false;
  // The last song ended with repeat off; play starts it again from 0.
  bool _ended = false;
  // True while the user wants sound, so an error while restoring (nothing
  // playing) doesn't start skipping through the queue.
  bool _wantsPlay = false;
  // A start is waiting on the engine; its own failure is handled there.
  bool _starting = false;
  int _playToken = 0;
  int _lastSavedSecond = -1;
  int _failures = 0;
  Timer? _sleepTimer;
  Timer? _saveTimer;
  // Rapid edits (a drag through the queue, several "add to queue") are
  // written once, this long after the last one.
  static const _saveDelay = Duration(milliseconds: 300);
  final List<StreamSubscription<Object?>> _subscriptions = [];

  PlaybackQueue get queue => _queue;

  @override
  Song? get current => _queue.current;

  List<Song> get upNext => _queue.songs;

  bool get shuffling => _queue.shuffling;

  // The song "Next" would play: the following one, or the first one when
  // repeat all wraps around.
  Song? get nextSong {
    final songs = _queue.songs;
    if (_queue.hasNext) return songs[_queue.index + 1];
    if (repeatMode == RepeatMode.all && songs.length > 1) return songs.first;
    return null;
  }

  // Null whenever no timer is running, even though the last length is kept.
  Duration? get sleepDuration => sleepUntil == null ? null : _sleepDuration;

  Duration? get sleepRemaining {
    final until = sleepUntil;
    if (until == null) return null;
    final remaining = until.difference(DateTime.now());
    if (remaining.isNegative) return Duration.zero;
    return remaining;
  }

  // While "end of track" is armed the engine only holds the current song,
  // so it stops at that song's end instead of moving on.
  int get _engineIndex => stopAfterCurrent ? 0 : _queue.index;

  List<PlaybackTrack> get _engineTracks => stopAfterCurrent
      ? [if (current != null) _trackFor(current!)]
      : [for (final song in _queue.songs) _trackFor(song)];

  Future<void> prepare() async {
    speed = _repository.playback().speed;
    await _engine.configure();
    await _engine.setSpeed(speed);
    await restore();
  }

  Future<bool> play(Song song,
      {required List<Song> queue, required int index}) async {
    _queue = PlaybackQueue(songs: queue, startIndex: index);
    _failures = 0;
    return _startCurrent(countPlay: true, reload: true);
  }

  Future<void> toggle() async {
    if (current == null) return;
    if (isPlaying) {
      await pause();
      return;
    }
    if (_ended) {
      // The engine finished the list; start the last song again explicitly.
      _ended = false;
      _wantsPlay = true;
      await _engine.seek(Duration.zero);
      position.value = Duration.zero;
      await _engine.play();
      isPlaying = true;
      notifyListeners();
      return;
    }
    if (_loaded) {
      _wantsPlay = true;
      await _engine.play();
      return;
    }
    await _startCurrent(countPlay: false, from: position.value);
  }

  // Play from the media session: does nothing while already playing.
  @override
  Future<void> resume() async {
    if (!isPlaying) await toggle();
  }

  @override
  Future<void> pause() async {
    _wantsPlay = false;
    await _engine.pause();
    await saveNow();
  }

  @override
  Future<void> next() async {
    if (!_queue.skipNext(repeatMode)) {
      await pause();
      return;
    }
    await _startCurrent(countPlay: true);
  }

  // Like most players: a few seconds in, Previous restarts the song instead.
  static const _restartThreshold = Duration(seconds: 3);
  static const _iosLibraryScheme = 'ipod-library://';
  // Forward skips stop this far before the end and let the song finish by
  // itself: seeking exactly to the end isn't guaranteed to end the item on
  // iOS, where AVFoundation reports the end when playback reaches it.
  static const seekEndMargin = Duration(milliseconds: 50);

  @override
  Future<void> previous() async {
    if (position.value > _restartThreshold) {
      await seek(Duration.zero);
      return;
    }
    if (!_queue.skipPrevious()) {
      await seek(Duration.zero);
      return;
    }
    await _startCurrent(countPlay: true);
  }

  // Notifies so the media session republishes the new position; ordinary
  // position ticks only update the position notifier.
  @override
  Future<void> seek(Duration value) async {
    await _engine.seek(value);
    position.value = value;
    notifyListeners();
  }

  // Skips within the song; negative rewinds. Rewind stops at 0. Forward
  // stops just short of the end so the song finishes and the queue moves on
  // as usual (repeat and the "end of track" timer included), and is ignored
  // while the song's length is unknown.
  @override
  Future<void> seekBy(Duration delta) async {
    if (current == null) return;
    var target = position.value + delta;
    if (delta > Duration.zero) {
      if (duration <= Duration.zero) return;
      final last = duration - seekEndMargin;
      if (target > last) target = last < Duration.zero ? Duration.zero : last;
    }
    if (target < Duration.zero) target = Duration.zero;
    await seek(target);
  }

  Future<void> jumpTo(int index) async {
    _queue.jumpTo(index);
    await _startCurrent(countPlay: true);
  }

  void toggleShuffle() {
    if (_queue.shuffling) {
      _queue.shuffleOff();
    } else {
      _queue.shuffleOn();
    }
    notifyListeners();
    _mirrorAround();
    _saveSoon();
  }

  void cycleRepeat() {
    repeatMode = switch (repeatMode) {
      RepeatMode.off => RepeatMode.all,
      RepeatMode.all => RepeatMode.one,
      RepeatMode.one => RepeatMode.off,
    };
    notifyListeners();
    if (!stopAfterCurrent) _engine.setRepeat(repeatMode);
    _saveSoon();
  }

  void playNext(Song song) {
    // Moving the playing song behind itself would make another song current
    // while this one keeps playing.
    if (song.path == current?.path) return;
    _queue.playNext(song);
    notifyListeners();
    _mirrorAround();
    _saveSoon();
  }

  void addToQueue(Song song) {
    final before = _queue.songs.length;
    _queue.addToEnd(song);
    if (_queue.songs.length == before) return;
    notifyListeners();
    if (_loaded && !stopAfterCurrent) {
      _engine.insertTrack(before, _trackFor(song));
    }
    _saveSoon();
  }

  void removeFromQueue(int index) {
    final removingCurrent = index == _queue.index;
    _queue.removeAt(index);
    notifyListeners();
    if (removingCurrent) {
      if (current == null) {
        stop();
      } else {
        _startCurrent(countPlay: true, reload: true);
      }
    } else if (_loaded && !stopAfterCurrent) {
      _engine.removeTrack(index);
    }
    _saveSoon();
  }

  void reorderQueue(int oldIndex, int newIndex) {
    final target = newIndex.clamp(0, _queue.songs.length - 1);
    _queue.reorder(oldIndex, newIndex);
    notifyListeners();
    if (_loaded && !stopAfterCurrent && oldIndex != target) {
      _engine.moveTrack(oldIndex, target);
    }
    _saveSoon();
  }

  Future<void> setSpeed(double value) async {
    speed = value;
    await _engine.setSpeed(value);
    notifyListeners();
    _saveSoon();
  }

  void startSleepTimer(Duration duration) {
    _sleepTimer?.cancel();
    _disarmEndOfTrack();
    sleepUntil = DateTime.now().add(duration);
    _sleepDuration = duration;
    _sleepTimer = Timer(duration, () {
      pause();
      sleepUntil = null;
      notifyListeners();
    });
    notifyListeners();
  }

  void sleepAfterCurrentTrack() {
    _sleepTimer?.cancel();
    sleepUntil = null;
    if (!stopAfterCurrent) {
      stopAfterCurrent = true;
      if (_loaded) {
        _engine.replaceAround(before: const [], after: const []);
        _engine.setRepeat(RepeatMode.off);
      }
    }
    notifyListeners();
  }

  void cancelSleep() {
    _sleepTimer?.cancel();
    sleepUntil = null;
    _disarmEndOfTrack();
    notifyListeners();
  }

  Future<void> stop() async {
    _saveTimer?.cancel();
    _playToken++;
    _wantsPlay = false;
    await _engine.stop();
    _queue = PlaybackQueue(songs: const []);
    _loaded = false;
    _ended = false;
    isPlaying = false;
    duration = Duration.zero;
    position.value = Duration.zero;
    await _repository.clearPlayback();
    notifyListeners();
  }

  // Loads the saved queue (playing order and, if shuffled, the original
  // order), repeat and position into the engine without playing it. Songs
  // no longer in the library are dropped; the saved song stays current if
  // it is still there.
  Future<void> restore() async {
    final snapshot = _repository.playback();
    speed = snapshot.speed;
    final order = _songsAt(snapshot.paths);
    if (order.isEmpty) return;
    final original = _songsAt(snapshot.originalPaths);
    final savedPath =
        snapshot.index >= 0 && snapshot.index < snapshot.paths.length
            ? snapshot.paths[snapshot.index]
            : null;
    final found = order.indexWhere((song) => song.path == savedPath);
    _queue = PlaybackQueue.restored(
      order: order,
      original: original.isEmpty ? order : original,
      shuffled: snapshot.shuffling,
      startIndex: found >= 0 ? found : snapshot.index,
    );
    repeatMode = snapshot.repeat;
    final resumeAt = Duration(milliseconds: snapshot.positionMs);
    position.value = resumeAt;
    notifyListeners();
    _loaded = await _engine.setQueue(_engineTracks,
        index: _engineIndex, position: resumeAt);
    await _engine.setRepeat(repeatMode);
  }

  List<Song> _songsAt(List<String> paths) => [
        for (final path in paths)
          if (_repository.songByPath(path) case final song?) song,
      ];

  static PlaybackTrack _trackFor(Song song) => PlaybackTrack(
      path: song.path, isUrl: song.path.startsWith(_iosLibraryScheme));

  // Starts the current song: loads the whole list when the engine doesn't
  // hold it, otherwise just moves within it. A newer start overtakes an
  // older one still waiting on the engine, and the older one stops there.
  Future<bool> _startCurrent({
    required bool countPlay,
    bool reload = false,
    bool keepError = false,
    Duration from = Duration.zero,
  }) async {
    final song = current;
    if (song == null) return false;
    final token = ++_playToken;
    if (!keepError) error = null;
    _wantsPlay = true;
    _ended = false;
    _lastSavedSecond = -1;
    position.value = from;
    final bool loaded;
    _starting = true;
    try {
      loaded = reload || !_loaded || stopAfterCurrent
          ? await _engine.setQueue(_engineTracks,
              index: _engineIndex, position: from)
          : await _engine.seekToIndex(_engineIndex, position: from);
    } finally {
      _starting = false;
    }
    if (token != _playToken) return false;
    if (!loaded) return _skipFailed(song);
    _loaded = true;
    await _engine.play();
    if (token != _playToken) return false;
    isPlaying = true;
    if (countPlay) {
      await _repository.recordPlay(song);
      await _onPlayed();
    }
    notifyListeners();
    await saveNow();
    return true;
  }

  // "Cannot play <title>." stays up while the next song starts. A full pass
  // of failures stops instead of looping through broken files forever.
  Future<bool> _skipFailed(Song failed) async {
    error = 'Cannot play ${failed.title}.';
    _loaded = false;
    _failures++;
    final skipMode =
        repeatMode == RepeatMode.all ? RepeatMode.all : RepeatMode.off;
    if (_failures >= _queue.songs.length || !_queue.skipNext(skipMode)) {
      _wantsPlay = false;
      isPlaying = false;
      await _engine.pause();
      notifyListeners();
      return false;
    }
    notifyListeners();
    return _startCurrent(countPlay: true, reload: true, keepError: true);
  }

  // Edits that keep the current song (shuffle, play next, ending the "end
  // of track" trim) rebuild the engine's list around it.
  void _mirrorAround() {
    if (!_loaded || stopAfterCurrent) return;
    final songs = _queue.songs;
    final index = _queue.index;
    _engine.replaceAround(
      before: [for (final song in songs.take(index)) _trackFor(song)],
      after: [for (final song in songs.skip(index + 1)) _trackFor(song)],
    );
  }

  void _disarmEndOfTrack() {
    if (!stopAfterCurrent) return;
    stopAfterCurrent = false;
    _mirrorAround();
    if (_loaded) _engine.setRepeat(repeatMode);
  }

  void _bindEngine() {
    _subscriptions.addAll([
      _engine.playingChanges.listen((playing) {
        if (playing == isPlaying) return;
        isPlaying = playing;
        notifyListeners();
      }),
      _engine.positionChanges.listen((value) {
        position.value = value;
        if (value > Duration.zero) _failures = 0;
        if (value.inSeconds != _lastSavedSecond && value.inSeconds % 5 == 0) {
          _lastSavedSecond = value.inSeconds;
          saveNow();
        }
      }),
      _engine.durationChanges.listen((value) {
        duration = value;
        notifyListeners();
      }),
      _engine.trackChanges.listen(_handleTrackChange),
      _engine.queueCompleted.listen((_) => _handleQueueCompleted()),
      _engine.errors.listen(_handleError),
    ]);
  }

  // The platform moved on by itself: the previous song ended, or repeat
  // started it again. Repeat one doesn't count as a new play.
  Future<void> _handleTrackChange(TrackChange change) async {
    if (!change.automatic || stopAfterCurrent) return;
    final sameSong = change.index == _queue.index;
    _queue.jumpTo(change.index);
    _lastSavedSecond = -1;
    position.value = Duration.zero;
    notifyListeners();
    final song = current;
    if (song != null && !(sameSong && repeatMode == RepeatMode.one)) {
      await _repository.recordPlay(song);
      await _onPlayed();
    }
    await saveNow();
  }

  Future<void> _handleQueueCompleted() async {
    _wantsPlay = false;
    // The engine still counts itself as playing after the end.
    await _engine.pause();
    isPlaying = false;
    if (stopAfterCurrent) {
      _disarmEndOfTrack();
      await seek(Duration.zero);
      notifyListeners();
      await saveNow();
      return;
    }
    _ended = true;
    position.value = Duration.zero;
    notifyListeners();
    await saveNow();
  }

  // Errors while a song plays, or right after the platform moved to the
  // next one. An error for a song the queue has already left is ignored.
  void _handleError(PlaybackError failure) {
    if (_starting || !_wantsPlay || current == null) return;
    final index = failure.index ?? _engineIndex;
    if (index != _engineIndex) {
      final movedOn = !stopAfterCurrent &&
          (index == _queue.index + 1 ||
              (repeatMode == RepeatMode.all && index == 0 && !_queue.hasNext));
      if (!movedOn) return;
      _queue.jumpTo(index);
    }
    debugPrint('Playback failed: ${failure.message}');
    _skipFailed(current!);
  }

  // Writes the queue, both orders when shuffled, the position, speed,
  // repeat and shuffle at once, dropping any save still waiting.
  Future<void> saveNow() async {
    _saveTimer?.cancel();
    _saveTimer = null;
    final song = current;
    if (song == null) return;
    await _repository.savePlayback(
      PlaybackSnapshot(
        paths: [for (final item in _queue.songs) item.path],
        index: _queue.index,
        positionMs: position.value.inMilliseconds,
        speed: speed,
        originalPaths: _queue.shuffling
            ? [for (final item in _queue.originalSongs) item.path]
            : const [],
        shuffling: _queue.shuffling,
        repeat: repeatMode,
      ),
    );
  }

  void _saveSoon() {
    _saveTimer?.cancel();
    _saveTimer = Timer(_saveDelay, saveNow);
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    _saveTimer?.cancel();
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    position.dispose();
    _engine.dispose();
    super.dispose();
  }
}
