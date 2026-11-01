import 'package:audio_service/audio_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musicplayer/core/models/song_model.dart';
import 'package:musicplayer/core/services/media_session_handler.dart';

import 'support/fake_playback_controls.dart';

const _song = Song(
  path: '/music/a.mp3',
  title: 'Song A',
  artist: 'Artist A',
  album: 'Album A',
);

void main() {
  late FakePlaybackControls player;
  late MediaSessionHandler handler;

  setUp(() {
    player = FakePlaybackControls()
      ..current = _song
      ..duration = const Duration(minutes: 3)
      ..speed = 1.25
      ..position.value = const Duration(seconds: 42);
    handler = MediaSessionHandler()..attach(player);
  });

  group('system actions go to the player', () {
    test('play, pause, next and previous', () async {
      await handler.play();
      await handler.pause();
      await handler.skipToNext();
      await handler.skipToPrevious();

      expect(player.calls, ['resume', 'pause', 'next', 'previous']);
    });

    test('seek, and the 10-second skips use seekBy', () async {
      await handler.seek(const Duration(seconds: 70));
      await handler.fastForward();
      await handler.rewind();

      expect(player.calls, ['seek:70', 'seekBy:10', 'seekBy:-10']);
    });

    test('headset and Bluetooth buttons toggle, skip and go back', () async {
      await handler.click();
      player
        ..isPlaying = true
        ..changed();
      await handler.click();
      await handler.click(MediaButton.next);
      await handler.click(MediaButton.previous);

      expect(player.calls, ['resume', 'pause', 'next', 'previous']);
    });
  });

  group('published state', () {
    test('playing shows pause in the middle of five controls', () {
      player
        ..isPlaying = true
        ..changed();
      final state = handler.playbackState.value;

      expect(state.controls, [
        MediaControl.rewind,
        MediaControl.skipToPrevious,
        MediaControl.pause,
        MediaControl.skipToNext,
        MediaControl.fastForward,
      ]);
      expect(state.androidCompactActionIndices, [1, 2, 3]);
      expect(state.systemActions, {
        MediaAction.seek,
        MediaAction.skipToNext,
        MediaAction.skipToPrevious,
        MediaAction.fastForward,
        MediaAction.rewind,
      });
      expect(state.controls, isNot(contains(MediaControl.stop)));
      expect(state.processingState, AudioProcessingState.ready);
      expect(state.playing, isTrue);
      expect(state.speed, 1.25);
      expect(state.updatePosition, const Duration(seconds: 42));
    });

    test('paused shows play and stays ready', () {
      final state = handler.playbackState.value;

      expect(state.controls[2], MediaControl.play);
      expect(state.playing, isFalse);
      expect(state.processingState, AudioProcessingState.ready);
    });

    test('nothing loaded is idle with no song', () {
      player
        ..current = null
        ..changed();

      expect(handler.playbackState.value.processingState,
          AudioProcessingState.idle);
      expect(handler.mediaItem.value, isNull);
    });

    test('the song has title, artist, album and length, and no artwork', () {
      final item = handler.mediaItem.value!;

      expect(item.id, _song.path);
      expect(item.title, 'Song A');
      expect(item.artist, 'Artist A');
      expect(item.album, 'Album A');
      expect(item.duration, const Duration(minutes: 3));
      expect(item.artUri, isNull);
    });

    test('an unknown length is left out', () {
      player
        ..duration = Duration.zero
        ..changed();

      expect(handler.mediaItem.value!.duration, isNull);
    });
  });

  test('position ticks are not republished; a seek is', () async {
    final states = <PlaybackState>[];
    final subscription = handler.playbackState.skip(1).listen(states.add);

    for (var second = 43; second < 60; second++) {
      player.position.value = Duration(seconds: second);
    }
    await pumpEventQueue();
    expect(states, isEmpty);

    player
      ..position.value = const Duration(seconds: 90)
      ..changed();
    await pumpEventQueue();
    expect(states, hasLength(1));
    expect(states.single.updatePosition, const Duration(seconds: 90));

    await subscription.cancel();
  });

  test('swiping the notification away pauses, keeps the queue and goes idle',
      () async {
    await handler.onNotificationDeleted();

    expect(player.calls, ['pause']);
    expect(
        handler.playbackState.value.processingState, AudioProcessingState.idle);

    player.changed();
    expect(
        handler.playbackState.value.processingState, AudioProcessingState.idle,
        reason: 'stays dismissed while paused');

    player
      ..isPlaying = true
      ..changed();
    expect(handler.playbackState.value.processingState,
        AudioProcessingState.ready);
  });

  test('the notification config has no ongoing or close behavior', () {
    const config = MediaSessionHandler.config;

    expect(config.androidNotificationChannelId, MediaSessionHandler.channelId);
    expect(config.androidNotificationChannelName, 'Playback');
    expect(config.androidNotificationIcon, 'drawable/ic_notification');
    expect(config.androidNotificationOngoing, isFalse);
    expect(config.androidStopForegroundOnPause, isTrue);
    expect(config.fastForwardInterval, const Duration(seconds: 10));
    expect(config.rewindInterval, const Duration(seconds: 10));
  });
}
