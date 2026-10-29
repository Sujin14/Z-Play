import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../models/song_model.dart';
import '../data/library_repository.dart';
import 'playback_queue.dart';
import '../models/playback_snapshot_model.dart';
import '../models/repeat_mode_model.dart';

class PlayerViewModel extends ChangeNotifier {
  PlayerViewModel({
    required LibraryRepository repository,
    required Future<void> Function() onPlayed,
    AudioPlayer? player,
  })  : _repository = repository,
        _onPlayed = onPlayed,
        _player = player ?? AudioPlayer() {
    _bindPlayer();
  }

  final LibraryRepository _repository;
  final Future<void> Function() _onPlayed;
  final AudioPlayer _player;
  final ValueNotifier<Duration> position = ValueNotifier(Duration.zero);

  PlaybackQueue _queue = PlaybackQueue(songs: const []);
  RepeatMode repeatMode = RepeatMode.off;
  bool isPlaying = false;
  bool stopAfterCurrent = false;
  Duration duration = Duration.zero;
  double speed = 1;
  String? error;
  DateTime? sleepUntil;
  Duration _sleepDuration = Duration.zero;
  bool _started = false;
  int _playToken = 0;
  int _lastSavedSecond = -1;
  Timer? _sleepTimer;
  StreamSubscription<PlayerState>? _stateSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<void>? _completeSubscription;

  PlaybackQueue get queue => _queue;

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

  Future<void> prepare() async {
    speed = _repository.playback().speed;
    await _applyAudioContext();
    await _player.setPlaybackRate(speed);
    await _player.setReleaseMode(ReleaseMode.stop);
    await restore();
  }

  Future<bool> play(Song song,
      {required List<Song> queue, required int index}) async {
    position.value = Duration.zero;
    _started = false;
    _queue = PlaybackQueue(songs: queue, startIndex: index);
    return _startCurrent(countPlay: true);
  }

  Future<void> toggle() async {
    if (current == null) return;
    if (isPlaying) {
      await pause();
      return;
    }
    if (_started) {
      await _player.resume();
      return;
    }
    await _startCurrent(countPlay: false);
  }

  Future<void> pause() async {
    await _player.pause();
    await _persist();
  }

  Future<void> next() async {
    if (!_queue.skipNext(repeatMode)) {
      await pause();
      return;
    }
    await _startCurrent(countPlay: true);
  }

  // Like most players: a few seconds in, Previous restarts the song instead.
  static const _restartThreshold = Duration(seconds: 3);

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

  Future<void> seek(Duration value) async {
    await _player.seek(value);
    position.value = value;
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
    _persist();
  }

  void cycleRepeat() {
    repeatMode = switch (repeatMode) {
      RepeatMode.off => RepeatMode.all,
      RepeatMode.all => RepeatMode.one,
      RepeatMode.one => RepeatMode.off,
    };
    notifyListeners();
  }

  void playNext(Song song) {
    _queue.playNext(song);
    notifyListeners();
    _persist();
  }

  void addToQueue(Song song) {
    _queue.addToEnd(song);
    notifyListeners();
    _persist();
  }

  void removeFromQueue(int index) {
    final removingCurrent = index == _queue.index;
    _queue.removeAt(index);
    notifyListeners();
    if (removingCurrent) {
      if (current == null) {
        stop();
      } else {
        _startCurrent(countPlay: true);
      }
    }
    _persist();
  }

  void reorderQueue(int oldIndex, int newIndex) {
    _queue.reorder(oldIndex, newIndex);
    notifyListeners();
    _persist();
  }

  Future<void> setSpeed(double value) async {
    speed = value;
    await _player.setPlaybackRate(value);
    notifyListeners();
    await _persist();
  }

  void startSleepTimer(Duration duration) {
    _sleepTimer?.cancel();
    stopAfterCurrent = false;
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
    stopAfterCurrent = true;
    notifyListeners();
  }

  void cancelSleep() {
    _sleepTimer?.cancel();
    sleepUntil = null;
    stopAfterCurrent = false;
    notifyListeners();
  }

  Future<void> stop() async {
    _playToken++;
    await _player.stop();
    _queue = PlaybackQueue(songs: const []);
    _started = false;
    isPlaying = false;
    duration = Duration.zero;
    position.value = Duration.zero;
    await _repository.clearPlayback();
    notifyListeners();
  }

  Future<void> restore() async {
    final snapshot = _repository.playback();
    speed = snapshot.speed;
    final songs = [
      for (final path in snapshot.paths)
        if (_repository.songByPath(path) != null) _repository.songByPath(path)!,
    ];
    if (songs.isEmpty) return;
    _queue = PlaybackQueue(
      songs: songs,
      startIndex: snapshot.index.clamp(0, songs.length - 1),
    );
    position.value = Duration(milliseconds: snapshot.positionMs);
    _started = false;
    notifyListeners();
  }

  Future<bool> _startCurrent({required bool countPlay}) async {
    final song = current;
    if (song == null) return false;
    final token = ++_playToken;
    final resumeAt = _started ? Duration.zero : position.value;
    error = null;
    try {
      await _player.stop();
      if (token != _playToken) return false;
      position.value = resumeAt;
      await _player.play(DeviceFileSource(song.path));
      await _player.setPlaybackRate(speed);
      if (token != _playToken) return false;
      if (resumeAt > Duration.zero) {
        await _player.seek(resumeAt);
      }
      _started = true;
      isPlaying = true;
      if (countPlay) {
        await _repository.recordPlay(song);
        await _onPlayed();
      }
      notifyListeners();
      await _persist();
      return true;
    } catch (exception) {
      error = 'Cannot play ${song.title}.';
      isPlaying = false;
      debugPrint('Playback failed: $exception');
      notifyListeners();
      return false;
    }
  }

  void _bindPlayer() {
    _stateSubscription = _player.onPlayerStateChanged.listen((state) {
      final playing = state == PlayerState.playing;
      if (playing == isPlaying) return;
      isPlaying = playing;
      notifyListeners();
    });
    _positionSubscription = _player.onPositionChanged.listen((value) {
      position.value = value;
      if (value.inSeconds != _lastSavedSecond && value.inSeconds % 5 == 0) {
        _lastSavedSecond = value.inSeconds;
        _persist();
      }
    });
    _durationSubscription = _player.onDurationChanged.listen((value) {
      duration = value;
      notifyListeners();
    });
    _completeSubscription = _player.onPlayerComplete.listen((_) {
      _handleComplete();
    });
  }

  Future<void> _handleComplete() async {
    if (stopAfterCurrent) {
      stopAfterCurrent = false;
      await pause();
      await seek(Duration.zero);
      notifyListeners();
      return;
    }
    if (repeatMode == RepeatMode.one) {
      await seek(Duration.zero);
      await _player.resume();
      return;
    }
    final moved = _queue.skipNext(repeatMode);
    if (!moved) {
      isPlaying = false;
      position.value = Duration.zero;
      notifyListeners();
      await _persist();
      return;
    }
    position.value = Duration.zero;
    await _startCurrent(countPlay: true);
  }

  Future<void> _persist() async {
    final song = current;
    if (song == null) return;
    await _repository.savePlayback(
      PlaybackSnapshot(
        paths: [for (final item in _queue.songs) item.path],
        index: _queue.index,
        positionMs: position.value.inMilliseconds,
        speed: speed,
      ),
    );
  }

  Future<void> _applyAudioContext() async {
    try {
      final context = AudioContext(
        android: const AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: true,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.gain,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
        ),
      );
      await _player.setAudioContext(context);
    } catch (exception) {
      debugPrint('Audio focus setup skipped: $exception');
    }
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    _stateSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _completeSubscription?.cancel();
    position.dispose();
    _player.dispose();
    super.dispose();
  }
}
