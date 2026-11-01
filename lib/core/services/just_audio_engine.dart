import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../models/playback_error_model.dart';
import '../models/playback_track_model.dart';
import '../models/repeat_mode_model.dart';
import '../models/track_change_model.dart';
import 'playback_engine.dart';

// just_audio keeps the whole list on the platform, so the next track starts
// natively (gapless) instead of from Dart. Speed is a player setting and
// carries over to every track. Interruptions are just_audio's defaults:
// pause on a call or Siri and resume afterwards only if it was playing,
// let Android duck music by itself, pause when headphones are unplugged.
class JustAudioEngine implements PlaybackEngine {
  JustAudioEngine({AudioPlayer? player}) : _player = player ?? AudioPlayer() {
    _subscriptions.addAll([
      _player.positionDiscontinuityStream
          .where((discontinuity) =>
              discontinuity.reason == PositionDiscontinuityReason.autoAdvance)
          .listen((discontinuity) {
        final index = discontinuity.event.currentIndex;
        if (index != null) {
          _trackChanges.add(TrackChange(index: index, automatic: true));
        }
      }),
      _player.errorStream.listen((error) => _errors.add(PlaybackError(
          index: error.index, message: error.message ?? 'Playback error'))),
    ]);
  }

  final AudioPlayer _player;
  final _subscriptions = <StreamSubscription<Object?>>[];
  final _trackChanges = StreamController<TrackChange>.broadcast();
  final _errors = StreamController<PlaybackError>.broadcast();

  @override
  Future<void> configure() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
    } catch (exception) {
      debugPrint('Audio session setup skipped: $exception');
    }
  }

  @override
  Future<bool> setQueue(
    List<PlaybackTrack> tracks, {
    required int index,
    Duration position = Duration.zero,
  }) async {
    try {
      await _player.setAudioSources(
        [for (final track in tracks) _sourceFor(track)],
        initialIndex: index,
        initialPosition: position,
      );
      _trackChanges.add(TrackChange(index: index, automatic: false));
      return true;
    } on PlayerInterruptedException {
      // A newer setQueue replaced this one before it finished loading.
      return false;
    } catch (exception) {
      _errors.add(PlaybackError(index: index, message: '$exception'));
      return false;
    }
  }

  // just_audio's play() only completes when playback stops, so it is not
  // awaited; a failure to start arrives as an error instead.
  @override
  Future<void> play() async {
    unawaited(_player.play().catchError((Object exception) {
      _errors.add(
          PlaybackError(index: _player.currentIndex, message: '$exception'));
    }));
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<bool> seekToIndex(int index,
      {Duration position = Duration.zero}) async {
    try {
      await _player.seek(position, index: index);
      _trackChanges.add(TrackChange(index: index, automatic: false));
      return true;
    } catch (exception) {
      _errors.add(PlaybackError(index: index, message: '$exception'));
      return false;
    }
  }

  @override
  Future<void> setSpeed(double speed) => _player.setSpeed(speed);

  @override
  Future<void> setRepeat(RepeatMode mode) => _player.setLoopMode(switch (mode) {
        RepeatMode.off => LoopMode.off,
        RepeatMode.all => LoopMode.all,
        RepeatMode.one => LoopMode.one,
      });

  @override
  Future<void> insertTrack(int index, PlaybackTrack track) =>
      _player.insertAudioSource(index, _sourceFor(track));

  @override
  Future<void> removeTrack(int index) => _player.removeAudioSourceAt(index);

  @override
  Future<void> moveTrack(int from, int to) => _player.moveAudioSource(from, to);

  // The current source object stays in the list throughout, so the platform
  // never sees a change of track.
  @override
  Future<void> replaceAround({
    required List<PlaybackTrack> before,
    required List<PlaybackTrack> after,
  }) async {
    final current = _player.currentIndex;
    final length = _player.audioSources.length;
    if (current == null || length == 0) return;
    if (current + 1 < length) {
      await _player.removeAudioSourceRange(current + 1, length);
    }
    if (current > 0) await _player.removeAudioSourceRange(0, current);
    if (before.isNotEmpty) {
      await _player.insertAudioSources(
          0, [for (final track in before) _sourceFor(track)]);
    }
    if (after.isNotEmpty) {
      await _player
          .addAudioSources([for (final track in after) _sourceFor(track)]);
    }
  }

  @override
  Stream<bool> get playingChanges => _player.playerStateStream
      .map((state) =>
          state.playing && state.processingState != ProcessingState.completed)
      .distinct();

  @override
  Stream<Duration> get positionChanges => _player.positionStream;

  @override
  Stream<Duration> get durationChanges =>
      _player.durationStream.where((value) => value != null).cast<Duration>();

  @override
  Stream<TrackChange> get trackChanges => _trackChanges.stream;

  @override
  Stream<void> get queueCompleted => _player.processingStateStream
      .where((state) => state == ProcessingState.completed);

  @override
  Stream<PlaybackError> get errors => _errors.stream;

  @override
  Future<void> dispose() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    await _trackChanges.close();
    await _errors.close();
    await _player.dispose();
  }

  // iOS library songs are ipod-library:// asset URLs; AVFoundation opens
  // them by URL. Everything else is a file on the device.
  static AudioSource _sourceFor(PlaybackTrack track) => track.isUrl
      ? AudioSource.uri(Uri.parse(track.path))
      : AudioSource.file(track.path);
}
